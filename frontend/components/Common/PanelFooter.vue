<template>
    <footer id="footer">
        {{ $gettext('Powered by') }}
        <a
            href="https://w3K.dev/"
            target="_blank"
        >w3K</a>
        &bull;
        <span v-html="version"/>
        &bull;
        <span v-html="platform"/><br>
        {{ $gettext('Forked from an amazing project you need to support:') }}
        <a
            href="https://donate.azuracast.com/"
            target="_blank"
        >
            {{ $gettext('AzuraCast!') }}
        </a>
    </footer>
</template>

<script setup lang="ts">
import { useAzuraCastDashboardGlobals } from "~/vendor/azuracast.ts";

const { version, platform } = useAzuraCastDashboardGlobals();
</script>
