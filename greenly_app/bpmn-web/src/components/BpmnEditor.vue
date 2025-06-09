<template>
  <div class="container-fluid h-100">
    <div class="row h-100">
      <!-- Sidebar danh sách quy trình -->
      <div class="col-3 bg-light border-end overflow-auto py-3">
        <h5 class="mb-3">Danh sách quy trình</h5>
        <div class="d-flex justify-content-between align-items-center mb-3">
          <button class="btn btn-success mb-3" @click="createNewProcess">Tạo quy trình mới</button>

          <button class="btn btn-primary mb-3" @click="exportXML">Export XML</button>
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

const canvasRef = ref(null)
const propertiesPanelRef = ref(null)
const modeler = ref(null)
const processes = ref([])
const selectedProcessId = ref(null)
const processName = ref('')

onMounted(async () => {
  modeler.value = new BpmnModeler({
    container: canvasRef.value,
    propertiesPanel: {
      parent: propertiesPanelRef.value,
    },
    additionalModules: [
      BpmnPropertiesPanelModule,
      BpmnPropertiesProviderModule,
      CamundaPlatformPropertiesProviderModule,
    ],
    moddleExtensions: {
      camunda: camundaModdle,
    },
  })

  await fetchProcesses()
})

const fetchProcesses = async () => {
  try {
    const res = await axios.get('/api/v1/bpmn/allxml')
    processes.value = res.data.data // [{ process_id, xml_content }]
    console.log('Danh sách quy trình:', res.data.data)
    console.log('Danh sách quy trình:', processes.value)
    // if (processes.value.length > 0) {
    //   // Tải quy trình đầu tiên nếu có
    //   await loadProcess(processes.value[0].process_id)
    // }
  } catch (err) {
    console.error('Lỗi tải danh sách quy trình:', err)
  }
}
const createNewProcess = async () => {
  try {
    selectedProcessId.value = null
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
    console.log('Tạo mới quy trình trống thành công')
  } catch (err) {
    console.error('Lỗi khi tạo process mới:', err)
  }
}
const loadProcess = async (id) => {
  try {
    selectedProcessId.value = id
    const res = await axios.get(`/api/v1/bpmn/${id}`)
    processName.value = res.data.data.name
    await modeler.value.importXML(res.data.data.xml_content)
  } catch (err) {
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
    fetchProcesses() // Refresh the process list
    return result
  } catch (err) {
    console.error('Export failed:', err)
  }
}

// const exportXML = async () => {
//   try {
//     const { xml } = await modeler.value.saveXML({ format: true })
//     const blob = new Blob([xml], { type: 'application/xml' })
//     const url = URL.createObjectURL(blob)

//     const link = document.createElement('a')
//     link.href = url
//     link.download = `${selectedProcessId.value || 'diagram'}.bpmn`
//     link.click()

//     URL.revokeObjectURL(url)
//   } catch (err) {
//     console.error('Export thất bại:', err)
//   }
// }
</script>

<style scoped>
/* html,
body,
#app,
.container-fluid {
  height: 100%;
} */
</style>
