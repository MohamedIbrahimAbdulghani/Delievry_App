<?php

namespace App\Support\Responses;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Http\Resources\Json\ResourceCollection;
use Symfony\Component\HttpFoundation\Response;

class ApiResponse
{
    public static function success(mixed $data = [], string $message = '', int $status = Response::HTTP_OK): JsonResponse
    {
        return response()->json([
            'status' => true,
            'message' => $message,
            'data' => self::normalizeData($data),
        ], $status);
    }

    public static function error(string $message, mixed $data = [], int $status = Response::HTTP_BAD_REQUEST): JsonResponse
    {
        return response()->json([
            'status' => false,
            'message' => $message,
            'data' => self::normalizeData($data),
        ], $status);
    }

    protected static function normalizeData(mixed $data): mixed
    {
        if ($data instanceof JsonResource) {
            return $data->resolve();
        }

        if ($data instanceof ResourceCollection) {
            return $data->resolve();
        }

        return $data;
    }
}
