<template>
  <div class="container-fluid h-100">
    <div class="row h-100">
      <div class="col-3 h-100 bg-light border-end p-3">
        <h5>Danh sách thư viện</h5>
        <div class="d-flex justify-content-between align-items-center mb-3">
          <button @click="createNewDocument" class="btn btn-success mb-3">Tạo mới</button>
        </div>

        <div v-if="isLoading">Đang tải...</div>

        <div v-else>
          <div
            v-for="doc in documentList"
            :key="doc.library_id"
            class="document-item p-2 mb-2 border rounded"
            @click="openDocument(doc)"
          >
            {{ doc.library_name }}
          </div>
          <div v-if="documentList.length === 0">Chưa có tài liệu nào</div>
        </div>
      </div>

      <div class="col-9 h-100">
        <div class="p-3">
          <h5>Tên tài liệu</h5>
          <input
            v-model="edittableName"
            class="form-control"
            placeholder="Nhập tên tài liệu"
            :class="{ 'is-invalid': touchedName && !edittableName }"
            @blur="touchedName = true"
          />
          <div v-if="touchedName && !edittableName" class="invalid-feedback">
            Vui lòng nhập tên tài liệu!
          </div>
        </div>

        <div class="p-3">
          <h5>Mô tả tài liệu</h5>
          <textarea
            v-model="edittableDescription"
            class="form-control"
            rows="5"
            placeholder="Nhập mô tả tài liệu"
          ></textarea>
        </div>

        <div class="p-3">
          <h5>Chọn quy trình</h5>
          <select
            v-model="selectedProcessId"
            class="form-select"
            @blur="touchedProcess = true"
            :class="{ 'is-invalid': touchedProcess && !selectedProcessId }"
          >
            <option disabled value="">-- Chọn quy trình --</option>
            <option v-for="p in processes" :key="p.process_id" :value="p.process_id">
              {{ p.name || p.process_id }}
            </option>
          </select>
          <div v-if="touchedProcess && !selectedProcessId" class="invalid-feedback">
            Vui lòng chọn quy trình!
          </div>
        </div>

        <div class="p-3">
          <h5>Chọn danh mục</h5>
          <select
            v-model="selectedCategoryId"
            class="form-select"
            @blur="touchedCategory = true"
            :class="{ 'is-invalid': touchedCategory && !selectedCategoryId }"
          >
            <option disabled value="">-- Chọn danh mục --</option>
            <option v-for="c in categories" :key="c.category_id" :value="c.category_id">
              {{ c.category_name }}
            </option>
          </select>
          <div v-if="touchedCategory && !selectedCategoryId" class="invalid-feedback">
            Vui lòng chọn danh mục!
          </div>
        </div>

        <div class="p-3">
          <h5>Tệp đính kèm</h5>
          <input
            ref="fileInput"
            type="file"
            @change="handleFileChange"
            @blur="touchedFile = true"
            class="form-control mb-1"
            :class="{ 'is-invalid': touchedFile && !selectedFile }"
          />
          <div v-if="touchedFile && !selectedFile" class="invalid-feedback">
            Vui lòng chọn tệp đính kèm!
          </div>
        </div>

        <div class="d-flex justify-content-end gap-2 p-3">
          <button
            v-if="!currentDocument"
            @click="saveDocument"
            class="btn btn-primary"
            :disabled="!edittableName"
          >
            Lưu
          </button>
          <button
            v-if="currentDocument"
            @click="updateDocument(currentDocument)"
            class="btn btn-warning"
          >
            Cập nhật
          </button>
          <button
            @click="deleteDocument(currentDocument)"
            class="btn btn-danger"
            :disabled="!currentDocument"
          >
            Xóa
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'

// References for data
const documentList = ref([])
const currentDocument = ref(null)
const isLoading = ref(false)
const edittableName = ref('')
const edittableDescription = ref('')

const selectedFile = ref(null)
const selectedFileName = ref('')

const fileInput = ref(null)

const processes = ref([])
const selectedProcessId = ref('')

const categories = ref([])
const selectedCategoryId = ref('')

const touchedName = ref(false)
const touchedFile = ref(false)
const touchedProcess = ref(false)
const touchedCategory = ref(false)

const fetchProcesses = async () => {
  try {
    const res = await axios.get('/api/v1/bpmn/allxml')
    processes.value = res.data.data
    console.log('Danh sách quy trình:', processes.value)
  } catch (err) {
    alert('Lỗi tải danh sách quy trình: ' + err.message)
    console.error('Lỗi tải danh sách quy trình:', err)
  }
}

// const selectProcess = (event) => {
//   selectedProcessId.value = event.target.value
//   console.log('⚙️ Quy trình đã chọn:', selectedProcessId.value)
// }
const fetchCategories = async () => {
  try {
    const response = await axios.get('/api/category/all?limit=10&page=1')
    categories.value = response.data.data['categories'] // giả sử trả về dạng [{ category_id, name }]
    console.log('📁 Danh sách category:', categories.value)
  } catch (err) {
    alert('Lỗi tải danh mục: ' + err.message)
    console.error('Lỗi tải danh mục:', err)
  }
}

// const selectCategory = (event) => {
//   selectedCategoryId.value = event.target.value
//   console.log('📌 Category đã chọn:', selectedCategoryId.value)
// }

const loadDocuments = async () => {
  console.log('Loading documents...')
  isLoading.value = true

  try {
    const response = await axios.get('/api/v1/library/content/all_content')

    documentList.value = response.data.data

    console.log('Loaded documents:', documentList.value)
  } catch (error) {
    console.error('Error loading documents:', error)
    alert('Không thể tải tài liệu!')
  } finally {
    isLoading.value = false
  }
}

const openDocument = (document) => {
  console.log('Opening document:', document.text_content)
  currentDocument.value = document
  edittableName.value = document.library_name
  edittableDescription.value = document.description || ''
  selectedFile.value = document.file
  selectedFileName.value = getFileUrl(document.file) || ''
  selectedProcessId.value = document.process_id || ''
  selectedCategoryId.value = document.category_id || ''
}

const handleFileChange = (event) => {
  const file = event.target.files[0]
  if (file) {
    selectedFile.value = file
    selectedFileName.value = file.name
  } else {
    selectedFile.value = null
    selectedFileName.value = ''
  }
}

const getFileUrl = (filePath) => {
  return `${filePath}`
}
const validateBeforeSave = () => {
  touchedName.value = true
  touchedFile.value = true
  touchedProcess.value = true
  touchedCategory.value = true

  return (
    edittableName.value && selectedFile.value && selectedProcessId.value && selectedCategoryId.value
  )
}
const createNewDocument = () => {
  currentDocument.value = null
  edittableName.value = ''
  edittableDescription.value = ''
  selectedFile.value = null
  selectedFileName.value = ''
  selectedProcessId.value = ''
  selectedCategoryId.value = ''
}

const saveDocument = async () => {
  if (!validateBeforeSave) {
    return
  }

  try {
    const formData = new FormData()

    formData.append('library_name', edittableName.value)
    formData.append('description', edittableDescription.value)
    formData.append('file', selectedFile.value)
    formData.append('process_id', selectedProcessId.value || '')
    formData.append('category_id', selectedCategoryId.value || '')

    const response = await axios.post('/api/v1/library/content', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    })

    if (response.data.status === 'success') {
      alert('Tài liệu đã được lưu thành công!')
      await loadDocuments()
      console.log(documentList.value)
      createNewDocument()

      fileInput.value = null
    } else {
      alert('Lưu tài liệu không thành công!')
    }
  } catch (error) {
    console.error('Error saving document:', error)
    alert('Không thể lưu tài liệu!')
  }
}

const updateDocument = async (currentDocument) => {
  if (!currentDocument || !currentDocument.library_id) {
    console.error('Invalid document to update:', document)
    return
  }

  try {
    const formData = new FormData()
    formData.append('library_name', edittableName.value)
    formData.append('description', edittableDescription.value)
    formData.append('process_id', selectedProcessId.value || '')
    formData.append('category_id', selectedCategoryId.value || '')

    if (selectedFile.value) {
      formData.append('file', selectedFile.value)
    }
    const response = await axios.put(
      `/api/v1/library/content/${currentDocument.library_id}`,
      formData,
      {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      },
    )

    if (response.data.status === 'success') {
      alert('Tài liệu đã được cập nhật thành công!')
      fileInput.value.value = null

      await loadDocuments() // Reload documents after update

      const updated = documentList.value.find(
        (doc) => doc.library_id === currentDocument.library_id,
      )
      openDocument(updated)
    } else {
      alert('Cập nhật tài liệu không thành công!')
    }
  } catch (error) {
    console.error('Error updating document:', error)
    alert('Không thể cập nhật tài liệu!')
  }
}

const deleteDocument = async (currentDocument) => {
  if (!currentDocument || !currentDocument.library_id) {
    console.error('Invalid document ID:', currentDocument.library_id)
    return
  }

  try {
    const response = await axios.delete(`/api/v1/library/content/${currentDocument.library_id}`)

    if (response.data.status === 'success') {
      alert('Tài liệu đã được xóa thành công!')
      loadDocuments()
      createNewDocument() // Reset form after deletion
    } else {
      alert('Xóa tài liệu không thành công!')
    }
  } catch (error) {
    console.error('Error deleting document:', error)
    alert('Không thể xóa tài liệu!')
  }
}

onMounted(() => {
  loadDocuments()
  fetchProcesses()
  fetchCategories()
})
</script>

<style scoped>
.document-item {
  cursor: pointer;
  transition: background-color 0.2s;
}

.document-item:hover {
  background-color: #f0f0f0;
}
.is-invalid {
  border-color: #dc3545;
}

.invalid-feedback {
  color: #dc3545;
  font-size: 0.875rem;
}
</style>
