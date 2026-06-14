<?php

namespace App\Modules\Notifications\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Notifications\Http\Resources\NotificationResource;
use App\Modules\Notifications\Models\Notification;
use App\Modules\Notifications\Services\NotificationService;
use App\Support\Responses\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function __construct(
        protected NotificationService $notificationService
    ) {}

    public function index(Request $request): JsonResponse
    {
        $notifications = $this->notificationService->getNotificationsForUser($request->user());
        return ApiResponse::success(NotificationResource::collection($notifications));
    }

    public function markAsRead(Notification $notification): JsonResponse
    {
        if ($notification->user_id !== auth()->id()) {
            abort(403);
        }

        $updated = $this->notificationService->markAsRead($notification);
        return ApiResponse::success(new NotificationResource($updated), __('Notification marked as read.'));
    }

    public function markAllAsRead(Request $request): JsonResponse
    {
        $this->notificationService->markAllAsReadForUser($request->user());
        return ApiResponse::success(null, __('All notifications marked as read.'));
    }

    public function stream(Request $request): \Symfony\Component\HttpFoundation\StreamedResponse
    {
        $response = new \Symfony\Component\HttpFoundation\StreamedResponse(function () use ($request) {
            $user = $request->user();
            $lastId = (int) $request->query('last_id', 0);
            
            set_time_limit(0);
            
            if (ob_get_level() > 0) {
                ob_end_clean();
            }
            
            echo "data: " . json_encode(['connected' => true]) . "\n\n";
            ob_flush();
            flush();
            
            while (true) {
                if (connection_aborted()) {
                    break;
                }
                
                $notifications = Notification::where('user_id', $user->id)
                    ->where('id', '>', $lastId)
                    ->orderBy('id', 'asc')
                    ->get();
                    
                if ($notifications->isNotEmpty()) {
                    foreach ($notifications as $notification) {
                        echo "data: " . json_encode(new NotificationResource($notification)) . "\n\n";
                        $lastId = $notification->id;
                    }
                    ob_flush();
                    flush();
                }
                
                sleep(2);
            }
        });
        
        $response->headers->set('Content-Type', 'text/event-stream');
        $response->headers->set('Cache-Control', 'no-cache');
        $response->headers->set('Connection', 'keep-alive');
        $response->headers->set('X-Accel-Buffering', 'no');
        
        return $response;
    }
}
