<template>
  <body class="d-flex flex-column h-100">
    <NavBar />
    <div class="flex-fill overflow-auto">
      <router-view />
    </div>
  </body>
</template>

<script setup>
import NavBar from './components/NavBar.vue'
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
