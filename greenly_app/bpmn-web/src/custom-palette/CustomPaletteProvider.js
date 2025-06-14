export default function CustomPaletteProvider(create, elementFactory, palette, translate) {
  this._create = create
  this._elementFactory = elementFactory
  this._translate = translate

  palette.registerProvider(this)
}

CustomPaletteProvider.$inject = ['create', 'elementFactory', 'palette', 'translate']

CustomPaletteProvider.prototype.getPaletteEntries = function () {
  const { _create: create, _elementFactory: elementFactory, _translate: t } = this

  function createElement(type, options = {}) {
    return function (event) {
      const shape = elementFactory.createShape({ type, ...options })
      create.start(event, shape)
    }
  }

  return {
    'create.start-event': {
      group: 'event',
      className: 'bpmn-icon-start-event-none',
      title: t('Bắt đầu'),
      action: {
        dragstart: createElement('bpmn:StartEvent'),
        click: createElement('bpmn:StartEvent'),
      },
    },
    'create.end-event': {
      group: 'event',
      className: 'bpmn-icon-end-event-none',
      title: t('Kết thúc'),
      action: {
        dragstart: createElement('bpmn:EndEvent'),
        click: createElement('bpmn:EndEvent'),
      },
    },
    'create.user-task': {
      group: 'activity',
      className: 'bpmn-icon-user-task',
      title: t('User Task'),
      action: {
        dragstart: createElement('bpmn:UserTask'),
        click: createElement('bpmn:UserTask'),
      },
    },
    'create.gateway': {
      group: 'gateway',
      className: 'bpmn-icon-gateway-xor',
      title: t('Exclusive Gateway'),
      action: {
        dragstart: createElement('bpmn:ExclusiveGateway'),
        click: createElement('bpmn:ExclusiveGateway'),
      },
    },
    'create.subprocess': {
      group: 'activity',
      className: 'bpmn-icon-subprocess-expanded',
      title: t('Subprocess'),
      action: {
        dragstart: createElement('bpmn:SubProcess', { isExpanded: true }),
        click: createElement('bpmn:SubProcess', { isExpanded: true }),
      },
    },
  }
}
