<template>
  <div class="container-fluid h-100">
    <div class="row h-100">
      <!-- Sidebar danh sách quy trình -->
      <div class="col-3 bg-light border-end overflow-auto py-3">
        <h5 class="mb-3">Danh sách quy trình</h5>
        <div class="d-flex justify-content-between align-items-center mb-3">
          <button class="btn btn-success mb-3" @click="createNewProcess">Tạo quy trình mới</button>
          <button v-if="!selectedProcessId" class="btn btn-primary mb-3" @click="exportXML">
            Lưu
          </button>
          <button v-if="selectedProcessId" class="btn btn-primary mb-3" @click="update">
            Cập nhật
          </button>
        </div>
        <div class="mb-3 position-relative">
          <input
            v-model="searchInput"
            @input="searchProcesses"
            @blur="((searchResults = []), (searchInput = ''))"
            placeholder="Tìm kiếm quy trình..."
            class="form-control"
          />
          <ul
            v-if="searchResults.length > 0"
            class="list-group position-absolute w-100 shadow mb-3"
            style="z-index: 10"
          >
            <li
              v-for="(proc, index) in searchResults"
              :key="index"
              class="list-group-item list-group-item-action"
              @click="selectProcess(proc)"
              style="cursor: pointer"
            >
              {{ proc.name }}
            </li>
          </ul>
        </div>
        <ul class="list-group">
          <li
            class="list-group-item"
            :class="{ active: selectedProcessId === proc.process_id }"
            v-for="(proc, index) in processes"
            :key="index"
            @click="loadProcess(proc.process_id)"
            style="cursor: pointer"
          >
            {{ proc.name }}
          </li>
        </ul>
      </div>

      <!-- Main BPMN editor -->
      <div class="col-9 position-relative p-0">
        <!-- Input tên -->
        <div class="position-absolute top-0 end-50 m-3 z-3">
          <input
            v-model="processName"
            placeholder="Tên quy trình"
            class="form-control"
            style="width: 300px"
          />
        </div>

        <!-- Canvas BPMN -->
        <div class="h-100 w-100" ref="canvasRef" style="background-color: white"></div>

        <!-- Panel thuộc tính -->
        <div
          ref="propertiesPanelRef"
          class="position-absolute top-0 end-0 h-100 border-start bg-light overflow-auto"
          style="width: 300px"
        ></div>
      </div>
    </div>
  </div>
  <BaseToast v-model="showToast" :message="toastMsg" />
</template>

<script setup>
import { onMounted, ref } from 'vue'
import axios from 'axios'
import BpmnModeler from 'bpmn-js/lib/Modeler'
import {
  BpmnPropertiesPanelModule,
  BpmnPropertiesProviderModule,
  CamundaPlatformPropertiesProviderModule,
} from 'bpmn-js-properties-panel'
import camundaModdle from 'camunda-bpmn-moddle/resources/camunda.json'

import 'bpmn-js/dist/assets/bpmn-js.css'
import 'bpmn-js/dist/assets/diagram-js.css'
import 'bpmn-js/dist/assets/bpmn-font/css/bpmn.css'
import '@bpmn-io/properties-panel/dist/assets/properties-panel.css'

import CustomPaletteModule from '../custom-palette/CustomPaletteModule.js'
import BaseToast from './ToastBase.vue'

const canvasRef = ref(null)
const propertiesPanelRef = ref(null)
const modeler = ref(null)
const processes = ref([])
const selectedProcessId = ref(null)
const newProcess = ref(null)
const processName = ref('')
const showToast = ref(false)
const toastMsg = ref('')
const searchInput = ref('')
const searchResults = ref([])

onMounted(async () => {
  modeler.value = new BpmnModeler({
    container: canvasRef.value,
    propertiesPanel: {
      parent: propertiesPanelRef.value,
    },
    additionalModules: [
      CustomPaletteModule,
      BpmnPropertiesPanelModule,
      BpmnPropertiesProviderModule,
      CamundaPlatformPropertiesProviderModule,
      // {
      //   __init__: ['customPaletteProvider'],
      //   customPaletteProvider: ['type', CustomPaletteProvider],
      // }
    ],
    moddleExtensions: {
      camunda: camundaModdle,
    },
  })

  await fetchProcesses()
})
const notify = (msg) => {
  showToast.value = true

  toastMsg.value = msg
}
const searchProcesses = () => {
  const keyword = searchInput.value.trim().toLowerCase()
  if (!keyword) {
    searchResults.value = []
    return
  }

  searchResults.value = processes.value.filter((proc) => proc.name.toLowerCase().includes(keyword))
}

const selectProcess = (proc) => {
  // processName.value = proc.name
  searchResults.value = []
  loadProcess(proc.process_id) // Gọi hàm loadProcess có sẵn
}
const fetchProcesses = async () => {
  try {
    const res = await axios.get('/api/v1/bpmn/processes')
    processes.value = res.data.data // [{ process_id, xml_content }]
    console.log('Danh sách quy trình:', res.data.data)
    console.log('Danh sách quy trình:', processes.value)
    // if (processes.value.length > 0) {
    //   // Tải quy trình đầu tiên nếu có
    //   await loadProcess(processes.value[0].process_id)
    // }
  } catch (err) {
    notify('Lỗi tải danh sách quy trình: ' + err.message)
    console.error('Lỗi tải danh sách quy trình:', err)
  }
}
const createNewProcess = async () => {
  try {
    selectedProcessId.value = null
    newProcess.value = 1
    processName.value = ''

    // XML cơ bản cho một process rỗng
    const emptyDiagram = `<?xml version="1.0" encoding="UTF-8"?>
      <bpmn:definitions xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                        xmlns:bpmn="http://www.omg.org/spec/BPMN/20100524/MODEL"
                        xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI"
                        xmlns:dc="http://www.omg.org/spec/DD/20100524/DC"
                        targetNamespace="http://bpmn.io/schema/bpmn">
        <bpmn:process id="Process_${Date.now()}" isExecutable="true">
        </bpmn:process>
        <bpmndi:BPMNDiagram id="BPMNDiagram_1">
          <bpmndi:BPMNPlane id="BPMNPlane_1" bpmnElement="Process_${Date.now()}"/>
        </bpmndi:BPMNDiagram>
      </bpmn:definitions>`

    await modeler.value.importXML(emptyDiagram)

    notify('Tạo mới quy trình trống thành công')
    console.log('Tạo mới quy trình trống thành công')
  } catch (err) {
    notify(`Lỗi khi tạo quy trình mới: ${err.message}`)
    console.error('Lỗi khi tạo process mới:', err)
  }
}
const loadProcess = async (id) => {
  try {
    selectedProcessId.value = id
    const res = await axios.get(`/api/v1/bpmn/${id}`)
    processName.value = res.data.data.name
    await modeler.value.importXML(res.data.data.xml_content)

    notify(`Tải quy trình ${processName.value} thành công`)
  } catch (err) {
    notify(`Lỗi tải quy trình ${id}: ${err.message}`)
    console.error(`Lỗi tải quy trình ${id}:`, err)
  }
}

const exportXML = async () => {
  try {
    const { xml } = await modeler.value.saveXML({ format: true })
    console.log('Exported XML:', xml)

    const elementRegistry = modeler.value.get('elementRegistry')
    const processElement = Array.from(elementRegistry.getAll()).find(
      (el) => el.type === 'bpmn:Process',
    )
    if (!processElement) {
      throw new Error('No process element found in the diagram')
    }

    const businessObject = processElement.businessObject
    const processId = businessObject.id || 'default_process_id'
    const processName = businessObject.name || 'Default Process Name'

    console.log('Process ID:', processId, 'Process Name:', processName)

    const properties = {
      process_id: processId,
      name: processName,
      xml_content: xml,
    }
    console.log('Properties to save:', properties)

    const response = await fetch('/api/v1/bpmn/process', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(properties),
    })

    if (!response.ok) {
      const errorText = await response.text()
      throw new Error('Failed to save BPMN diagram: ' + errorText)
    }

    const result = await response.json() // Parse JSON response per Swagger spec

    console.log('BPMN process saved successfully:', result)
    notify('Quy trình đã được lưu thành công: ' + processName)
    fetchProcesses() // Refresh the process list
    return result
  } catch (err) {
    notify('Lỗi khi lưu quy trình: ' + err.message)
    console.error('Export failed:', err)
  }
}
const update = async () => {
  try {
    const { xml } = await modeler.value.saveXML({ format: true })
    console.log('Exported XML:', xml)

    const elementRegistry = modeler.value.get('elementRegistry')
    const processElement = Array.from(elementRegistry.getAll()).find(
      (el) => el.type === 'bpmn:Process',
    )
    if (!processElement) {
      throw new Error('No process element found in the diagram')
    }

    const businessObject = processElement.businessObject
    const processId = businessObject.id || 'default_process_id'
    const processName = businessObject.name || 'Default Process Name'

    console.log('Process ID:', processId, 'Process Name:', processName)

    const properties = {
      name: processName,
      xml_content: xml,
    }
    console.log('Properties to save:', properties)
    console.log('Properties to save:', selectedProcessId.value)

    const response = await fetch(`/api/v1/bpmn/${processId}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(properties),
    })

    if (!response.ok) {
      const errorText = await response.text()
      throw new Error('Failed to save BPMN diagram: ' + errorText)
    }

    const result = await response.json() // Parse JSON response per Swagger spec
    console.log('BPMN process saved successfully:', result)
    fetchProcesses() // Refresh the process list

    notify('Quy trình đã được cập nhật thành công: ' + processName)
  } catch (err) {
    console.error('Export failed:', err)
    notify('Lỗi khi cập nhật quy trình: ' + err.message)
  }
}
</script>

<style scoped>
/* html,
  body,
  #app,
  .container-fluid {
    height: 100%;
  } */
/* .update-bnt {
  position: absolute;
  width: 100px;
  height: 40px;
  bottom: 10px;
  right: 10px;
  z-index: 1000;
} */
</style>
