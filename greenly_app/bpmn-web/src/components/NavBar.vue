<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
const auth = useAuthStore()
const router = useRouter()
const showDropdown = ref(false)
const user = ref(null)
function handleLogout() {
  auth.logout()
  router.push('/login')
}
const username = computed(() => auth.user?.username || 'Admin')
user.value = localStorage.getItem('user')
  ? JSON.parse(localStorage.getItem('user')).u_email
  : 'Admin'
</script>

<template>
  <nav class="navbar navbar-expand-lg navbar-light bg-light px-3">
    <a class="navbar-brand" href="#">Sống Xanh</a>
    <button
      class="navbar-toggler"
      type="button"
      data-bs-toggle="collapse"
      data-bs-target="#navbarNav"
      aria-controls="navbarNav"
      aria-expanded="false"
      aria-label="Toggle navigation"
    >
      <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="navbar-nav me-auto">
        <li class="nav-item">
          <router-link class="nav-link" to="/">Quản lý quy trình</router-link>
        </li>
        <li class="nav-item">
          <router-link class="nav-link" to="/quytrinh">Quản lý quy trình động</router-link>
        </li>
      </ul>

      <!-- User Dropdown -->
      <div class="dropdown" @mouseenter="showDropdown = true" @mouseleave="showDropdown = false">
        <button class="btn btn-outline-success dropdown-toggle" type="button">
          {{ username }}
        </button>
        <ul class="dropdown-menu custom-dropdown" :class="{ show: showDropdown }">
          <li><a class="dropdown-item" href="#">Thông tin</a></li>
          <li>
            <a class="dropdown-item" style="cursor: pointer" @click="handleLogout">Đăng xuất</a>
          </li>
        </ul>
      </div>
    </div>
  </nav>
</template>

<style scoped>
.custom-dropdown {
  right: 0;
  left: auto;
  position: absolute;
}
</style>
