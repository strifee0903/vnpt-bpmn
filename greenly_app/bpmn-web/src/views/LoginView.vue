<template>
  <div class="d-flex justify-content-center align-items-center vh-100 bg-light">
    <div class="card p-4 shadow" style="width: 100%; max-width: 400px">
      <h4 class="mb-3 text-center">Đăng nhập</h4>
      <form @submit.prevent="handleLogin">
        <div v-if="errorMessage" class="alert alert-danger" role="alert">{{ errorMessage }}</div>
        <div class="mb-3">
          <label for="email" class="form-label">Email</label>
          <input
            v-model="email"
            type="text"
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
const errorMessage = ref('')

const authStore = useAuthStore()
const router = useRouter()

const handleLogin = async () => {
  errorMessage.value = ''

  try {
    const formData = new FormData()
    formData.append('u_email', email.value)
    formData.append('u_pass', password.value)

    const response = await axios.post('/api/users/login/', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    })
    console.log('🔐 Đăng nhập thành công:', response.data)
    const user = response.data.data.user
    console.log('🔍 Thông tin người dùng:', user)
    if (user.role_id == 1) {
      authStore.login(user.u_email)
      router.push({ name: 'home' })
      console.log('✅ Đăng nhập thành công:', user)
    } else {
      authStore.logout()
      errorMessage.value = 'Tài khoản không có quyền truy cập trang quản trị.'
      console.warn('⚠️ Người dùng không phải admin')
    }
  } catch (error) {
    if (error.response) {
      errorMessage.value = error.response.data.message || 'Đăng nhập thất bại'
      console.error('Lỗi từ server:', error.response.data)
    } else {
      errorMessage.value = 'Không thể kết nối đến máy chủ.'
      console.error('Lỗi kết nối:', error.message)
    }
  }
}
</script>
