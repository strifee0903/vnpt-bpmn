<template>
  <component :is="layout">
    <router-view />
  </component>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import DefaultLayout from './layouts/DefaultLayout.vue'
import EmptyLayout from './layouts/NoNavLayout.vue'

const route = useRoute()
const layout = computed(() => (route.meta.layout === 'none' ? EmptyLayout : DefaultLayout))
</script>
<style>
/* html,
body,
#app {
  margin: 0;
  padding: 0;
  height: 100%;
  width: 100%;
} */
</style>
