<?php

namespace App\Modules\Notifications\Services;

use App\Models\User;
use App\Modules\Notifications\Models\Notification;

class NotificationService
{
    public function getNotificationsForUser(User $user)
    {
        return Notification::where('user_id', $user->id)
            ->orderBy('id', 'desc')
            ->get();
    }

    public function markAsRead(Notification $notification): Notification
    {
        $notification->update(['is_read' => true]);
        return $notification;
    }

    public function markAllAsReadForUser(User $user): void
    {
        Notification::where('user_id', $user->id)
            ->where('is_read', false)
            ->update(['is_read' => true]);
    }
}
