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


  await modeler.importXML(`
  <?xml version="1.0" encoding="UTF-8"?>
  <bpmn:definitions xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:bpmn="http://www.omg.org/spec/BPMN/20100524/MODEL" xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI" xmlns:dc="http://www.omg.org/spec/DD/20100524/DC" xmlns:di="http://www.omg.org/spec/DD/20100524/DI" id="Definitions_1" targetNamespace="http://bpmn.io/schema/bpmn">
    <bpmn:process id="Process_1" isExecutable="true">
      <bpmn:startEvent id="StartEvent_1">
        <bpmn:outgoing>Flow_0o3lzgd</bpmn:outgoing>
      </bpmn:startEvent>
      <bpmn:task id="Activity_17cm37v" name="B1: Ola">
        <bpmn:incoming>Flow_0o3lzgd</bpmn:incoming>
        <bpmn:outgoing>Flow_13z381a</bpmn:outgoing>
      </bpmn:task>
      <bpmn:sequenceFlow id="Flow_0o3lzgd" sourceRef="StartEvent_1" targetRef="Activity_17cm37v" />
      <bpmn:task id="Activity_138dngd" name="B2: Alo">
        <bpmn:incoming>Flow_13z381a</bpmn:incoming>
        <bpmn:outgoing>Flow_0p9a32d</bpmn:outgoing>
      </bpmn:task>
      <bpmn:sequenceFlow id="Flow_13z381a" sourceRef="Activity_17cm37v" targetRef="Activity_138dngd" />
      <bpmn:endEvent id="Event_0llmhg9">
        <bpmn:incoming>Flow_0p9a32d</bpmn:incoming>
      </bpmn:endEvent>
      <bpmn:sequenceFlow id="Flow_0p9a32d" sourceRef="Activity_138dngd" targetRef="Event_0llmhg9" />
    </bpmn:process>
    <bpmndi:BPMNDiagram id="BPMNDiagram_1">
      <bpmndi:BPMNPlane id="BPMNPlane_1" bpmnElement="Process_1">
        <bpmndi:BPMNShape id="StartEvent_1_di" bpmnElement="StartEvent_1">
          <dc:Bounds x="100" y="100" width="36" height="36" />
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape id="Activity_17cm37v_di" bpmnElement="Activity_17cm37v">
          <dc:Bounds x="200" y="78" width="100" height="80" />
          <bpmndi:BPMNLabel />
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape id="Activity_138dngd_di" bpmnElement="Activity_138dngd">
          <dc:Bounds x="370" y="78" width="100" height="80" />
          <bpmndi:BPMNLabel />
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape id="Event_0llmhg9_di" bpmnElement="Event_0llmhg9">
          <dc:Bounds x="542" y="100" width="36" height="36" />
        </bpmndi:BPMNShape>
        <bpmndi:BPMNEdge id="Flow_0o3lzgd_di" bpmnElement="Flow_0o3lzgd">
          <di:waypoint x="136" y="118" />
          <di:waypoint x="200" y="118" />
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge id="Flow_13z381a_di" bpmnElement="Flow_13z381a">
          <di:waypoint x="300" y="118" />
          <di:waypoint x="370" y="118" />
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge id="Flow_0p9a32d_di" bpmnElement="Flow_0p9a32d">
          <di:waypoint x="470" y="118" />
          <di:waypoint x="542" y="118" />
        </bpmndi:BPMNEdge>
      </bpmndi:BPMNPlane>
    </bpmndi:BPMNDiagram>
  </bpmn:definitions>
  `)

})
  const exportXML = async () => {
  try {
    const { xml } = await modeler.saveXML({ format: true });
    const blob = new Blob([xml], { type: 'application/xml' });
    const url = URL.createObjectURL(blob);
    
    const link = document.createElement('a');
    link.href = url;
    link.download = 'diagram.bpmn';
    link.click();

    URL.revokeObjectURL(url);
  } catch (err) {
    console.error('Export failed:', err);
  }
};  
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
  background: #ffffff; /* Thêm để dễ debug */
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
