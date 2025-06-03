import { createRouter, createWebHistory } from 'vue-router'
import BpmnEditorView from '../views/BpmnEditorView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: BpmnEditorView,
    },
  ],
})

export default router
