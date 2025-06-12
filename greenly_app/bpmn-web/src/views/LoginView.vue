<template>
  <div class="d-flex justify-content-center align-items-center vh-100 bg-light">
    <div class="card p-4 shadow" style="width: 100%; max-width: 400px">
      <h4 class="mb-3 text-center">Đăng nhập</h4>
      <form @submit.prevent="handleLogin">
        <div class="mb-3">
          <label for="email" class="form-label">Email</label>
          <input
            v-model="email"
            type="username"
            class="form-control"
            id="email"
            placeholder="name@example.com"
            required
          />
        </div>
        <div class="mb-3">
          <label for="password" class="form-label">Mật khẩu</label>
          <input
            v-model="password"
            type="password"
            class="form-control"
            id="password"
            placeholder="••••••••"
            required
          />
        </div>
        <button type="submit" class="btn btn-primary w-100">Đăng nhập</button>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import axios from 'axios'
import { useAuthStore } from '@/stores/auth'
import { useRouter } from 'vue-router'

const email = ref('')
const password = ref('')
const authStore = useAuthStore()
const router = useRouter()

const handleLogin = async () => {
  try {
    const formData = new FormData()
    formData.append('u_email', email.value)
    formData.append('u_pass', password.value)

    const response = await axios.post('/api/users/login/', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    })
    authStore.login(response.data.data.data.u_email)
    router.push({ name: 'home' }) // Chuyển hướng đến trang chính sau khi đăng nhập thành công
    console.log('Login thành công:', response.data.data.data)
  } catch (error) {
    if (error.response) {
      console.error('Lỗi từ server:', error.response.data)
    } else {
      console.error('Lỗi kết nối:', error.message)
    }
  }
}
</script>
