<?php

namespace App\Modules\Auth\Services;

use App\Models\User;
use App\Modules\Users\Http\Resources\UserResource;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;

class AuthService
{
    /**
     * @return array{user: UserResource, token: string}
     */
    public function register(string $name, string $email, string $password): array
    {
        $user = User::query()->create([
            'name' => $name,
            'email' => $email,
            'password' => $password,
            'is_admin' => false,
        ]);

        $token = $user->createToken('api')->plainTextToken;

        return [
            'user' => new UserResource($user),
            'token' => $token,
        ];
    }

    /**
     * @return array{user: UserResource, token: string}
     */
    public function login(string $email, string $password): array
    {
        if (! Auth::attempt(['email' => $email, 'password' => $password])) {
            throw ValidationException::withMessages([
                'email' => [__('Invalid credentials.')],
            ]);
        }

        /** @var User $user */
        $user = Auth::user();

        if ($user->is_blocked) {
            Auth::logout();
            throw ValidationException::withMessages([
                'email' => [__('Your account has been deactivated.')],
            ]);
        }

        $user->tokens()->delete();
        $token = $user->createToken('api')->plainTextToken;

        return [
            'user' => new UserResource($user),
            'token' => $token,
        ];
    }

    public function forgotPassword(string $email): void
    {
        $user = User::where('email', $email)->first();
        if (! $user) {
            throw ValidationException::withMessages([
                'email' => [__('User not found.')],
            ]);
        }

        $otp = (string) rand(100000, 999999);

        \Illuminate\Support\Facades\DB::table('password_reset_tokens')->updateOrInsert(
            ['email' => $email],
            [
                'token' => \Illuminate\Support\Facades\Hash::make($otp),
                'created_at' => now(),
            ]
        );

        // In a real app, send OTP via email/SMS here.
        // For this demo, we can log it or just assume it's sent.
        \Illuminate\Support\Facades\Log::info("OTP for $email: $otp");
    }

    public function verifyOtp(string $email, string $otp): void
    {
        $record = \Illuminate\Support\Facades\DB::table('password_reset_tokens')
            ->where('email', $email)
            ->first();

        if (! $record || ! \Illuminate\Support\Facades\Hash::check($otp, $record->token)) {
            throw ValidationException::withMessages([
                'otp' => [__('Invalid OTP.')],
            ]);
        }

        if (now()->parse($record->created_at)->addMinutes(15)->isPast()) {
            throw ValidationException::withMessages([
                'otp' => [__('OTP expired.')],
            ]);
        }
    }

    public function resetPassword(string $email, string $otp, string $password): void
    {
        $this->verifyOtp($email, $otp);

        $user = User::where('email', $email)->first();
        $user->update([
            'password' => $password,
        ]);

        \Illuminate\Support\Facades\DB::table('password_reset_tokens')->where('email', $email)->delete();
    }

    public function logout(User $user): void
    {
        $user->currentAccessToken()?->delete();
    }
}
