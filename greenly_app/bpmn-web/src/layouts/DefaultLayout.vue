<template>
  <div class="d-flex flex-column h-100">
    <NavBar />
    <div class="flex-fill overflow-auto">
      <slot />
    </div>
  </div>
</template>

<script setup>
import NavBar from '@/components/NavBar.vue'
</script>
