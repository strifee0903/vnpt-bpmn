<script setup>
import { ref, computed, onMounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import axios from 'axios'
import Choices from 'choices.js'
import 'choices.js/public/assets/styles/choices.min.css'
import BaseToast from './ToastBase.vue'
const auth = useAuthStore()
const router = useRouter()
const showDropdown = ref(false)
const user = ref(null)
const showToast = ref(false)
const toastMsg = ref('')
const showInfoModal = ref(false)
const showCateModal = ref(false)
const categories = ref([])
const selectedCategoryId = ref('')
const selectRef = ref(null)
const choicesInstance = ref(null)
const updatedCategoryName = ref('')
const previewImage = ref('')
const showCreateModal = ref(false)
const newCategoryName = ref('')
const newCategoryFile = ref(null)
const newCategoryPreview = ref(null)

function handleNewImage(event) {
  const file = event.target.files[0]
  if (file) {
    newCategoryFile.value = file
    const reader = new FileReader()
    reader.onload = (e) => {
      newCategoryPreview.value = e.target.result
    }
    reader.readAsDataURL(file)
  }
}
const notify = (msg) => {
  showToast.value = true

  toastMsg.value = msg
}
function handleLogout() {
  auth.logout()
  router.push('/login')
}
const username = computed(() => auth.user?.username || 'Admin')
user.value = localStorage.getItem('user')
  ? JSON.parse(localStorage.getItem('user')).u_email
  : 'Admin'

const fetchCategories = async () => {
  try {
    const response = await axios.get('/api/category/all?limit=10&page=1')
    categories.value = response.data.data.categories || []

    await nextTick() // đợi DOM cập nhật xong options mới

    // Nếu đã khởi tạo Choices rồi thì huỷ trước
    if (choicesInstance.value) {
      choicesInstance.value.destroy()
      choicesInstance.value = null
    }

    // Khởi tạo lại ChoicesJS
    choicesInstance.value = new Choices(selectRef.value, {
      searchEnabled: true,
      itemSelectText: '',
      shouldSort: false,
    })
  } catch (error) {
    console.error('Error fetching categories:', error)
  }
}

const updateCategory = async () => {
  try {
    if (!selectedCategoryId.value) return

    const formData = new FormData()
    formData.append('category_name', updatedCategoryName.value)

    if (fileInput.value?.files[0]) {
      formData.append('categoryImage', fileInput.value.files[0]) // append file thật
    }

    try {
      console.log('Updating category with ID:', selectedCategoryId.value)
      console.log('Form data:', formData)
      console.log('Updated category name:', updatedCategoryName.value)
      console.log('Selected file:', fileInput.value?.files[0])
      console.log('Preview image:', previewImage.value)

      const response = await axios.patch(
        `/api/category/update/${selectedCategoryId.value}`,
        formData,
        {
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        },
      )
      console.log('Cập nhật thành công:', response.data)
      // Cập nhật lại danh sách categories sau khi cập nhật
      await fetchCategories()
      selectedCategoryId.value = ''
    } catch (error) {
      console.error('Lỗi khi cập nhật:', error)
    }
  } catch (error) {
    console.error('Error updating category:', error)
    alert('Cập nhật thất bại')
  }
}
async function createCategory() {
  const formData = new FormData()
  formData.append('category_name', newCategoryName.value)
  if (newCategoryFile.value) {
    formData.append('categoryImage', newCategoryFile.value)
  }

  try {
    const res = await axios.post('/api/category/createCategory', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
    console.log('Created:', res.data)
    showCreateModal.value = false
    newCategoryName.value = ''
    newCategoryFile.value = null
    newCategoryPreview.value = null
    notify('Tạo danh mục thành công!')
    await fetchCategories() // cập nhật lại danh sách
  } catch (err) {
    console.error('Tạo danh mục thất bại:', err)
  }
}
const deleteCategory = async () => {
  try {
    if (!selectedCategoryId.value) return

    const response = await axios.delete(`/api/category/deleteCategory/${selectedCategoryId.value}`)
    if (response.status === 200) {
      console.log('Xóa thành công:', response.data)
      // Cập nhật lại danh sách categories sau khi xóa
      await fetchCategories()
      selectedCategoryId.value = ''
    } else {
      console.error('Xóa thất bại:', response.data)
    }
  } catch (error) {
    console.error('Lỗi khi xóa category:', error)
  }
}

const fileInput = ref(null)

function triggerFileSelect() {
  fileInput.value?.click()
}

function handleFileChange(event) {
  const file = event.target.files[0]
  if (file) {
    const reader = new FileReader()
    reader.onload = (e) => {
      previewImage.value = e.target.result // cập nhật ảnh preview
    }
    reader.readAsDataURL(file)
  }
}
onMounted(() => {
  fetchCategories().catch((error) => {
    console.error('Failed to fetch categories:', error)
  })
})
const selectedCategory = computed(() =>
  categories.value.find((cat) => cat.category_id === selectedCategoryId.value),
)
const imageUrl = computed(() => {
  return (
    previewImage.value ||
    (selectedCategory.value?.category_image
      ? `http://localhost:3000${selectedCategory.value.category_image}`
      : '')
  )
})
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
      <ul class="navbar-nav me-auto" style="cursor: pointer">
        <li class="nav-item">
          <router-link custom v-slot="{ isActive, navigate }" to="/"
            ><a class="nav-link" :class="{ active: isActive }" @click="navigate"
              >Quản lý quy trình</a
            ></router-link
          >
        </li>
        <li class="nav-item">
          <router-link to="/quytrinh" custom v-slot="{ isActive, navigate }">
            <a class="nav-link" :class="{ active: isActive }" @click="navigate"
              >Quản lý quy trình động</a
            >
          </router-link>
        </li>
        <li class="nav-item">
          <router-link to="/thuvien" custom v-slot="{ isActive, navigate }">
            <a class="nav-link" :class="{ active: isActive }" @click="navigate"
              >Thư viện</a
            >
          </router-link>
        </li>
      </ul>

      <!-- User Dropdown -->
      <div class="dropdown" @mouseenter="showDropdown = true" @mouseleave="showDropdown = false">
        <button class="btn btn-outline-success dropdown-toggle" type="button">
          {{ username }}
        </button>
        <ul class="dropdown-menu custom-dropdown" :class="{ show: showDropdown }">
          <li>
            <a class="dropdown-item" href="#" @click="showInfoModal = true">Thông tin</a>
          </li>
          <li>
            <a class="dropdown-item" href="#" @click="showCateModal = true">Category</a>
          </li>

          <li>
            <a class="dropdown-item" style="cursor: pointer" @click="handleLogout">Đăng xuất</a>
          </li>
        </ul>
      </div>
    </div>
  </nav>
  <div
    class="modal fade"
    tabindex="-1"
    :class="{ show: showInfoModal }"
    :style="{ display: showInfoModal ? 'block' : 'none' }"
    @click.self="showInfoModal = false"
  >
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">Thông tin người dùng</h5>
          <button type="button" class="btn-close" @click="showInfoModal = false"></button>
        </div>
        <div class="modal-body">
          <p><strong>Email:</strong> {{ username }}</p>
          <p><strong>Tên đăng nhập:</strong> {{ username }}</p>
          <!-- bé có thể hiển thị thêm thông tin tại đây -->
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" @click="showInfoModal = false">
            Đóng
          </button>
        </div>
      </div>
    </div>
  </div>
  <div v-if="showInfoModal" class="modal-backdrop fade show"></div>
  <div
    class="modal fade"
    tabindex="-1"
    :class="{ show: showCreateModal }"
    :style="{ display: showCreateModal ? 'block' : 'none' }"
    @click.self="showCreateModal = false"
  >
    <!-- Modal Tạo Danh Mục -->
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">Tạo danh mục mới</h5>
          <button type="button" class="btn-close" @click="showCreateModal = false"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label for="newCategoryName" class="form-label">Tên danh mục</label>
            <input
              type="text"
              id="newCategoryName"
              class="form-control"
              v-model="newCategoryName"
              placeholder="Nhập tên danh mục"
            />
          </div>

          <div class="mb-3">
            <label for="newCategoryImage" class="form-label">Ảnh danh mục</label>
            <input
              type="file"
              id="newCategoryImage"
              class="form-control"
              @change="handleNewImage"
            />
          </div>

          <div class="text-center" v-if="newCategoryPreview">
            <img :src="newCategoryPreview" class="img-thumbnail" style="max-width: 200px" />
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" @click="showCreateModal = false">
            Đóng
          </button>
          <button type="button" class="btn btn-primary" @click="createCategory">Tạo mới</button>
        </div>
      </div>
    </div>
  </div>
  <div v-if="showCreateModal" class="modal-backdrop fade show"></div>
  <div
    class="modal fade"
    tabindex="-1"
    :class="{ show: showCateModal }"
    :style="{ display: showCateModal ? 'block' : 'none' }"
    @click.self="showCateModal = false"
  >
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header">
          <div class="d-flex gap-2 align-items-center">
            <h5 class="modal-title">Phân loại</h5>
            <button
              type="button"
              class="btn btn-outline-primary"
              @click="((showCateModal = false), (showCreateModal = true))"
            >
              Tạo mới
            </button>
          </div>
          <button type="button" class="btn-close" @click="showCateModal = false"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label for="categorySelect" class="form-label">Chọn danh mục</label>
            <select
              id="categorySelect"
              ref="selectRef"
              class="form-select"
              v-model="selectedCategoryId"
            >
              <option value="" selected>-- Chọn danh mục --</option>
              <option v-for="cat in categories" :key="cat.category_id" :value="cat.category_id">
                {{ cat.category_name }}
              </option>
            </select>
          </div>
          <div class="d-flex mb-3 align-items-center gap-5 w-100" v-if="selectedCategoryId">
            <!-- <label for="categoryName" class="form-label mb-0" style="white-space: nowrap">
              Đổi ảnh
            </label> -->
            <input
              type="file"
              ref="fileInput"
              @change="handleFileChange"
              accept="image/*"
              style="display: none"
            />
            <div
              class="text-center position-relative image-hover-container"
              style="display: inline-block"
              @click="triggerFileSelect"
            >
              <img :src="imageUrl" alt="Ảnh danh mục" class="img-thumbnail border-1" />

              <!-- Overlay khi hover -->
              <div
                class="overlay position-absolute top-0 start-0 w-100 h-100 d-flex align-items-center justify-content-center"
              >
                <span>📷 Tải ảnh lên</span>
              </div>
            </div>
          </div>
          <div class="mb-3 d-flex align-items-center gap-5" v-if="selectedCategoryId">
            <!-- <label for="categoryName" class="form-label mb-0" style="white-space: nowrap">
              Đổi tên
            </label> -->
            <input
              type="text"
              class="form-control"
              id="categoryName"
              v-model="updatedCategoryName"
              placeholder="Nhập tên mới"
              @keyup.enter="updateCategory"
            />
          </div>
        </div>
        <div class="modal-footer">
          <div class="d-flex gap-2 justify-content-between w-100">
            <button
              type="button"
              class="btn btn-danger"
              @click="deleteCategory"
              v-if="selectedCategoryId"
            >
              Xóa
            </button>
            <button
              type="button"
              class="btn btn-outline-primary"
              @click="updateCategory"
              v-if="selectedCategoryId"
            >
              Cập nhật
            </button>
          </div>
          <!-- <button type="button" class="btn btn-secondary" @click="showCateModal = false">
            Đóng
          </button> -->
        </div>
      </div>
    </div>
  </div>
  <div v-if="showCateModal" class="modal-backdrop fade show"></div>
  <BaseToast v-model="showToast" :message="toastMsg" />
</template>
<style>
.image-hover-container {
  cursor: pointer;
  position: relative;
}

.image-hover-container .overlay {
  background-color: rgba(0, 0, 0, 0.5);
  color: white;
  opacity: 0;
  transition: opacity 0.3s;
}

.image-hover-container:hover .overlay {
  opacity: 1;
}
</style>
<style scoped>
.custom-dropdown {
  right: 0;
  left: auto;
  position: absolute;
}
</style>
