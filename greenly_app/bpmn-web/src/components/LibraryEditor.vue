<template>
    <div class="container-fluid h-100">
        <div class="row h-100">

            <div class="col-3 h-100 bg-light border-end p-3">
                <h5>Danh sách thư viện</h5>
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <button @click="createNewDocument" class="btn btn-success mb-3">
                        Tạo mới
                    </button>
                </div>

                <div v-if="isLoading">
                    Đang tải...
                </div>


                <div v-else>
                    <div v-for="doc in documentList" :key="doc.library_id" class="document-item p-2 mb-2 border rounded"
                        @click="openDocument(doc)">

                        {{ doc.library_name }}
                    </div>
                    <div v-if="documentList.length === 0">
                        Chưa có tài liệu nào
                    </div>
                </div>
            </div>


            <div class="col-9 h-100">
                <div class="p-3">
                    <h5>Tên tài liệu</h5>
                    <input v-model="edittableName" class="form-control" placeholder="Nhập tên tài liệu" />
                </div>

                <div class="p-3">
                    <h5>Mô tả tài liệu</h5>
                    <textarea v-model="edittableDescription" class="form-control" rows="5"
                        placeholder="Nhập mô tả tài liệu"></textarea>
                </div>

                <div class="p-3">
                    <h5>Tệp đính kèm</h5>
                    <input ref="fileInput" type="file" @change="handleFileChange" class="form-control mb-3" />

                    <div v-if="selectedFileName" class="text-muted mb-2">
                        Tệp đã chọn: {{ currentDocument.file }}

                    </div>

                </div>

                <div class="d-flex justify-content-end gap-2 p-3">
                    <button v-if="!currentDocument" @click="saveDocument" class="btn btn-primary"
                        :disabled="!edittableName">
                        Lưu
                    </button>
                    <button v-if="currentDocument" @click="updateDocument(currentDocument)" class="btn btn-warning">
                        Cập nhật
                    </button>
                    <button @click="deleteDocument(currentDocument)" class="btn btn-danger"
                        :disabled="!currentDocument">
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

const createNewDocument = () => {
    currentDocument.value = null
    edittableName.value = ''
    edittableDescription.value = ''
    selectedFile.value = null
    selectedFileName.value = ''
}

const saveDocument = async () => {
    if (!edittableName.value || !selectedFile.value) {
        alert('Vui lòng nhập tên tài liệu!')
        return
    }

    try {
        const formData = new FormData()

        formData.append('library_name', edittableName.value)
        formData.append('description', edittableDescription.value)
        formData.append('file', selectedFile.value)

        const response = await axios.post('/api/v1/library/content', formData, {
            headers: {
                'Content-Type': 'multipart/form-data'
            }
        })

        if (response.data.status === 'success') {
            alert('Tài liệu đã được lưu thành công!')
            await(loadDocuments())
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

        if (selectedFile.value) {
            formData.append('file', selectedFile.value)
        }
        const response = await axios.put(`/api/v1/library/content/${currentDocument.library_id}`, formData, {
            headers: {
                'Content-Type': 'multipart/form-data'
            }
        })

        if (response.data.status === 'success') {
            alert('Tài liệu đã được cập nhật thành công!')
            fileInput.value.value = null

            await(loadDocuments()) // Reload documents after update

            const updated = documentList.value.find(doc => doc.library_id === currentDocument.library_id)
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
</style>

