import { defineStore } from 'pinia'
import axios from 'axios'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
  }),
  getters: {
    isLoggedIn: (state) => !!state.user,
  },
  actions: {
    login(username) {
      this.user = { username }
      localStorage.setItem('user', JSON.stringify(this.user))
    },
    logout() {
      this.user = null
      localStorage.removeItem('user')
      axios
        .post('/api/users/logout')
        .then(() => {
          console.log('✅ Đăng xuất thành công')
        })
        .catch((error) => {
          console.error('❌ Lỗi khi đăng xuất:', error)
        })
    },
    restore() {
      const saved = localStorage.getItem('user')
      if (saved) {
        this.user = JSON.parse(saved)
      }
    },
  },
})
