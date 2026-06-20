<?php

declare(strict_types=1);

namespace App\Nginx;

use App\Entity\Station;
use App\Environment;
use App\Event\Nginx\WriteNginxConfiguration;
use Psr\EventDispatcher\EventDispatcherInterface;
use Supervisor\SupervisorInterface;
use Symfony\Component\Filesystem\Filesystem;

final class Nginx
{
    private const string PROCESS_NAME = 'nginx';

    public function __construct(
        private readonly SupervisorInterface $supervisor,
        private readonly EventDispatcherInterface $eventDispatcher
    ) {
    }

    public function writeConfiguration(
        Station $station,
        bool $reloadIfChanged = true,
    ): void {
        $configPath = $this->getConfigPath($station);

        $currentConfig = (is_file($configPath))
            ? file_get_contents($configPath)
            : null;

        $newConfig = $this->getConfiguration($station, true);

        $fs = new Filesystem();
        $changed = false;

        if ($currentConfig !== $newConfig) {
            $fs->dumpFile($configPath, $newConfig);
            $changed = true;
        }

        if ($this->writeCustomDomainConfiguration($station)) {
            $changed = true;
        }

        if ($changed && $reloadIfChanged) {
            $this->testConfiguration();
            $this->reload();
        }
    }

    public function writeCustomDomainConfiguration(Station $station): bool
    {
        $customDomainConfigPath = $this->getCustomDomainConfigPath($station);
        $fs = new Filesystem();

        if (empty($station->custom_domain)) {
            if (is_file($customDomainConfigPath)) {
                $fs->remove($customDomainConfigPath);
                return true;
            }
            return false;
        }

        $domain = $station->custom_domain;
        $stationSlug = $station->short_name;
        $streamPort = $station->frontend_config->port;

        $acmeDir = Environment::getInstance()->getParentDirectory() . '/storage/acme';

        $newConfig = <<<NGINX
        server {
            listen 80;
            listen 443 ssl;
            http2 on;

            ssl_certificate     {$acmeDir}/ssl.crt;
            ssl_certificate_key {$acmeDir}/ssl.key;
            ssl_protocols TLSv1.3 TLSv1.2;
            ssl_prefer_server_ciphers on;
            ssl_ciphers EECDH+AESGCM:EECDH+AES256;

            server_name {$domain};

            location ^~ /static {
                include /etc/nginx/proxy_params;
                proxy_pass http://127.0.0.1:6010;
            }
            location ^~ /api/live/ {
                rewrite ^/api/live/nowplaying/(.*)\$ /connection/uni_\$1 break;
                include /etc/nginx/proxy_params;
                proxy_set_header Upgrade \$http_upgrade;
                proxy_set_header Connection "upgrade";
                proxy_pass http://127.0.0.1:6020;
            }
            location ^~ /api {
                include /etc/nginx/proxy_params;
                proxy_pass http://127.0.0.1:6010;
            }
            location ^~ /docs {
                include /etc/nginx/proxy_params;
                proxy_pass http://127.0.0.1:6010;
            }
            location = /favicon.ico {
                include /etc/nginx/proxy_params;
                proxy_pass http://127.0.0.1:6010;
            }
            location = /public/sw.js {
                include /etc/nginx/proxy_params;
                proxy_pass http://127.0.0.1:6010;
            }
            location ^~ /listen/ {
                include /etc/nginx/proxy_params;
                proxy_intercept_errors    on;
                proxy_next_upstream       error timeout invalid_header;
                proxy_redirect            off;
                proxy_set_header          Cookie "";
                proxy_connect_timeout     60;
                set \$args \$args&_ic2=1;
                proxy_pass http://127.0.0.1:{$streamPort}/;
            }
            location ^~ /public/{$stationSlug} {
                include /etc/nginx/proxy_params;
                proxy_pass http://127.0.0.1:6010;
            }
            location = / {
                rewrite ^ /public/{$stationSlug} last;
            }
            location / {
                rewrite ^/(.+)\$ /public/{$stationSlug}/\$1 last;
            }
        }
        NGINX;

        $currentConfig = is_file($customDomainConfigPath)
            ? file_get_contents($customDomainConfigPath)
            : null;

        if ($currentConfig === $newConfig) {
            return false;
        }

        $fs->dumpFile($customDomainConfigPath, $newConfig);
        return true;
    }

    public function getConfiguration(
        Station $station,
        bool $writeToDisk = false
    ): string {
        $event = new WriteNginxConfiguration(
            $station,
            $writeToDisk
        );

        $this->eventDispatcher->dispatch($event);

        return $event->buildConfiguration();
    }

    public function testConfiguration(): void
    {
        exec('nginx -t 2>&1', $output, $exitCode);
        if ($exitCode !== 0) {
            throw new \RuntimeException('nginx config test failed: ' . implode("\n", $output));
        }
    }

    public function reload(): void
    {
        $this->supervisor->signalProcess(self::PROCESS_NAME, 'HUP');
    }

    public function reopenLogs(): void
    {
        $this->supervisor->signalProcess(self::PROCESS_NAME, 'USR1');
    }

    private function getConfigPath(Station $station): string
    {
        return $station->getRadioConfigDir() . '/nginx.conf';
    }

    private function getCustomDomainConfigPath(Station $station): string
    {
        return $station->getRadioConfigDir() . '/custom_domain.conf';
    }
}
