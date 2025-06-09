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
      },
    }
  ],
})

export default router
