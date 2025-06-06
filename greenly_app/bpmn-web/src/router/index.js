import { createRouter, createWebHistory } from 'vue-router'
import BpmnEditorView from '../views/BpmnEditorView.vue'
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
  ],
})

export default router
