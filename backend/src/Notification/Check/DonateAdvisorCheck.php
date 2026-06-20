<?php

declare(strict_types=1);

namespace App\Notification\Check;

use App\Container\EnvironmentAwareTrait;
use App\Entity\Api\Notification;
use App\Enums\FlashLevels;
use App\Event\GetNotifications;
use App\Exception\Http\RateLimitExceededException;

final class DonateAdvisorCheck
{
    use EnvironmentAwareTrait;

    public function __invoke(GetNotifications $event): void
    {
        if (!$this->environment->isProduction()) {
            return;
        }

        $request = $event->getRequest();

        $rateLimit = $request->getRateLimit();
        try {
            $rateLimit->checkRequestRateLimit($request, 'notification:donate', 600, 1);
        } catch (RateLimitExceededException) {
            return;
        }

        $event->addNotification(
            new Notification(
                id: 'notification-donation',
                title: __('Support AzuraCast — the project mETaLcast is built on.'),
                body: __(
                    'mETaLcast is a fork of AzuraCast. If you find it useful, please consider donating to ' .
                    'the AzuraCast project to help keep the upstream modern, accessible and free.',
                ),
                type: FlashLevels::Info,
                actionLabel: __('Donate to AzuraCast'),
                actionUrl: 'https://donate.azuracast.com/'
            )
        );
    }
}
