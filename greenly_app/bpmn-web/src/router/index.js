import { createRouter, createWebHistory } from 'vue-router'
import BpmnEditorView from '../views/BpmnEditorView.vue'
import ProcessPage from '@/views/ProcessPageView.vue' // Importing ProcessPage for the /quytrinh route
import LoginView from '@/views/LoginView.vue' // Importing LoginView if needed in the future

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: BpmnEditorView,
      meta: {
        title: 'BPMN Editor',
        layout: 'default',
        requiresAuth: true,
      },
    },
    {
      path: '/login',
      name: 'login',
      component: LoginView,
      meta: {
        title: 'Login',
        layout: 'none',
      },
    },
    {
      path: '/quytrinh',
      name: 'process',
      component: ProcessPage,
      meta: {
        title: 'Quy trình',
        layout: 'default',
        requiresAuth: true,
      },
    },
  ],
})
import { useAuthStore } from '@/stores/auth'

router.beforeEach((to, from, next) => {
  const auth = useAuthStore()

  if (to.meta.requiresAuth && !auth.isLoggedIn) {
    next({ name: 'login' })
  } else {
    next()
  }
})
export default router
