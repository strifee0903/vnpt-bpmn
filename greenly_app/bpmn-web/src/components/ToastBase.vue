<template>
  <div>
    <!-- Toast -->
    <div class="toast-container position-fixed top-0 end-0 p-3" style="z-index: 9999">
      <div
        class="toast align-items-center text-white bg-success border-0"
        ref="toastRef"
        role="alert"
        aria-live="assertive"
        aria-atomic="true"
        data-bs-delay="3000"
        data-bs-autohide="true"
      >
        <div class="d-flex">
          <div class="toast-body">
            {{ message }}
          </div>
          <button
            type="button"
            class="btn-close btn-close-white me-2 m-auto"
            data-bs-dismiss="toast"
            aria-label="Close"
          ></button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, nextTick } from 'vue'
import { Toast } from 'bootstrap'

const props = defineProps({
  modelValue: Boolean,
  message: String,
})

const emit = defineEmits(['update:modelValue'])

const toastRef = ref(null)
let toastInstance = null

watch(
  () => props.modelValue,
  async (val) => {
    if (val) {
      await nextTick()
      if (toastRef.value) {
        toastInstance = new Toast(toastRef.value)
        toastInstance.show()

        toastRef.value.addEventListener(
          'hidden.bs.toast',
          () => {
            emit('update:modelValue', false)
          },
          { once: true },
        )
      }
    }
  },
)
</script>
