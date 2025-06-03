<template>
  <div class="bpmn-wrapper">
    <!-- Sidebar danh sách quy trình -->
    <div class="sidebar">
      <h3>Danh sách quy trình</h3>
      <ul>
        <li v-for="(proc, index) in processes" :key="proc.process_id" @click="loadProcess(proc.process_id)" :class="{ active: selectedProcessId === proc.process_id }">
          {{ proc.name }}
        </li>
      </ul> 
    </div>

    <!-- BPMN canvas và panel -->
    <div class="bpmn-main">
      <div class="bpmn-canvas" ref="canvasRef"></div>
      <input v-model="processName" placeholder="Tên quy trình" class="process-name-input" />
      <div class="bpmn-properties" ref="propertiesPanelRef"></div>
      <button class="export-btn" @click="exportXML">Export XML</button>
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
  CamundaPlatformPropertiesProviderModule
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
      parent: propertiesPanelRef.value
    },
    additionalModules: [
      BpmnPropertiesPanelModule,
      BpmnPropertiesProviderModule,
      CamundaPlatformPropertiesProviderModule
    ],
    moddleExtensions: {
      camunda: camundaModdle
    }
  })

  await fetchProcesses()
})

const fetchProcesses = async () => {
  try {
    const res = await axios.get('/api/v1/bpmn/all')
    processes.value = res.data.data // [{ process_id, xml_content }]
    console.log('Danh sách quy trình:', res.data.data)
    console.log('Danh sách quy trình:', processes.value)
    if (processes.value.length > 0) {
      // Tải quy trình đầu tiên nếu có
      await loadProcess(processes.value[0].process_id)
    }
  } catch (err) {
    console.error('Lỗi tải danh sách quy trình:', err)
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

      const { xml } = await modeler.value.saveXML({ format: true });
      console.log('Exported XML:', xml);

      const elementRegistry = modeler.value.get('elementRegistry');
      const processElement = Array.from(elementRegistry.getAll()).find(el => el.type === 'bpmn:Process');
      if (!processElement) {
        throw new Error('No process element found in the diagram');
      }

      const businessObject = processElement.businessObject;
      const processId = businessObject.id || 'default_process_id';
      const processName = businessObject.name || 'Default Process Name';

      console.log('Process ID:', processId, "Process Name:", processName);

      const properties = {
        process_id: processId,
        name: processName,
        xml_content: xml,
      }
      console.log('Properties to save:', properties);
      
      const response = await fetch('/api/v1/bpmn/process', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(properties),
      });

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error('Failed to save BPMN diagram: ' + errorText);
      }

      const result = await response.json(); // Parse JSON response per Swagger spec
      console.log('BPMN process saved successfully:', result);
      return result;           
    } catch (err) {
      console.error('Export failed:', err);
    }                   
  };

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
.bpmn-wrapper {
  display: flex;
  height: 100vh;
  width: 100vw;
  overflow: hidden;
}

.name{
  position: absolute;
  top: 100px;
  left: 1rem;
  z-index: 10;
  font-size: 24px;
  color: #333;
}

.sidebar {
  width: 250px;
  background: #f1f1f1;
  border-right: 1px solid #ccc;
  padding: 1rem;
  overflow-y: auto;
}

.sidebar h3 {
  margin-top: 0;
}

.sidebar ul {
  list-style: none;
  padding: 0;
}

.sidebar li {
  cursor: pointer;
  padding: 0.5rem;
  margin-bottom: 0.5rem;
  background: white;
  border-radius: 4px;
  transition: background 0.2s;
}

.sidebar li:hover {
  background: #e0e0e0;
}

.sidebar li.active {
  background: #007bff;
  color: white;
}

.bpmn-main {
  display: flex;
  flex: 1;
  position: relative;
}

.bpmn-canvas {
  flex: 1;
  height: 100%;
  background: #ffffff;
}

.bpmn-properties {
  position: absolute;
  top: 0;
  right: 0;
  width: 300px;
  border-left: 1px solid #ccc;
  height: 100%;
  background: #f8f8f8;
  overflow: auto;
}

.export-btn {
  position: absolute;
  top: 1rem;
  right: 1rem;
  z-index: 10;
  padding: 0.5rem 1rem;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
}
.process-name-input {
  position: absolute;
  top: 1rem;
  left: 120px;
  z-index: 10;  
  padding: 8px;
  margin: 10px;
  font-size: 16px;
  width: 250px;
  height: 10px;
  border: 1px solid #ccc;
  border-radius: 4px;
}
</style>
