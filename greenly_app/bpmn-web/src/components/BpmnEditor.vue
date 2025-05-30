<template>
  <div class="alo"></div>
  <div class="bpmn-wrapper">
    <div class="bpmn-canvas" ref="canvasRef"></div>
    <div class="bpmn-properties" ref="propertiesPanelRef"></div>
    <button class="export-btn" @click="exportXML">Export XML</button>
  </div>
</template>
<script setup>
import { onMounted, ref } from 'vue'
// import BpmnModeler from 'bpmn-js/lib/Modeler'

// NEW: Import các module của properties panel (1.x+) 
import BpmnModeler from 'bpmn-js/lib/Modeler'
// import BpmnPropertiesPanelModule from 'bpmn-js-properties-panel'
 import {
   BpmnPropertiesPanelModule,
   BpmnPropertiesProviderModule,
    CamundaPlatformPropertiesProviderModule
  } from 'bpmn-js-properties-panel'

import camundaModdle from 'camunda-bpmn-moddle/resources/camunda.json'

// Styles mới
import 'bpmn-js/dist/assets/bpmn-js.css'
import 'bpmn-js/dist/assets/diagram-js.css'
import 'bpmn-js/dist/assets/bpmn-font/css/bpmn.css'; 
import '@bpmn-io/properties-panel/dist/assets/properties-panel.css'

// Refs
const canvasRef = ref(null)
const propertiesPanelRef = ref(null)


let modeler
  onMounted(async () => {
   modeler = new BpmnModeler({
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


  await modeler.importXML(`<?xml version="1.0" encoding="UTF-8"?>
    <bpmn:definitions xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xmlns:bpmn="http://www.omg.org/spec/BPMN/20100524/MODEL"
      xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI"
      xmlns:dc="http://www.omg.org/spec/DD/20100524/DC"
      xmlns:di="http://www.omg.org/spec/DD/20100524/DI"
      xmlns:camunda="http://camunda.org/schema/1.0/bpmn"
      id="Definitions_1"
      targetNamespace="http://bpmn.io/schema/bpmn">
      <bpmn:process id="Process_1" isExecutable="true">
        <bpmn:startEvent id="StartEvent_1"/>
      </bpmn:process>
      <bpmndi:BPMNDiagram id="BPMNDiagram_1">
        <bpmndi:BPMNPlane id="BPMNPlane_1" bpmnElement="Process_1">
          <bpmndi:BPMNShape id="StartEvent_1_di" bpmnElement="StartEvent_1">
            <dc:Bounds x="100" y="100" width="36" height="36"/>
          </bpmndi:BPMNShape>
        </bpmndi:BPMNPlane>
      </bpmndi:BPMNDiagram>
    </bpmn:definitions>
  `)
  console.log('canvasRef:', canvasRef.value)
console.log('propertiesPanelRef:', propertiesPanelRef.value)

})
</script>


<style scoped>

.bpmn-wrapper {
  display: flex;
  height: 100vh;
  width: 100vw;
  overflow: hidden;
  position: relative;
  background-color: #007bff;
}

.bpmn-canvas {
  flex: 1;
  height: 100%; /* QUAN TRỌNG */
  background: #321313; /* Thêm để dễ debug */
}

.bpmn-properties {
  width: 300px;
  border-left: 1px solid #ccc;
  height: 100%;
  background: #f8f8f8;
  overflow: auto;
}

.export-btn {
  position: absolute;
  top: 1rem;
  left: 1rem;
  z-index: 10;
  padding: 0.5rem 1rem;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
}
</style>
