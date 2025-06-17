export default function CustomPaletteProvider(create, elementFactory, palette, translate) {
  this._create = create
  this._elementFactory = elementFactory
  this._translate = translate

  palette.registerProvider(this)
}

CustomPaletteProvider.$inject = ['create', 'elementFactory', 'palette', 'translate']

CustomPaletteProvider.prototype.getPaletteEntries = function () {
  const { _create: create, _elementFactory: elementFactory, _translate: t } = this

  function createElement(type, options = {}, defaultName = '') {
    return function (event) {
      const shape = elementFactory.createShape({
        type,
        businessObject: {
          name: defaultName,
        },
        ...options,
      })
      create.start(event, shape)
    }
  }

  return {
    'create.start-event': {
      group: 'event',
      className: 'bpmn-icon-start-event-none',
      title: t('Bắt đầu'),
      action: {
        dragstart: createElement('bpmn:StartEvent', {}, 'Bắt đầu'),
        click: createElement('bpmn:StartEvent', {}, 'Bắt đầu'),
      },
    },
    'create.end-event': {
      group: 'event',
      className: 'bpmn-icon-end-event-none',
      title: t('Kết thúc'),
      action: {
        dragstart: createElement('bpmn:EndEvent', 'Kết thúc'),
        click: createElement('bpmn:EndEvent', 'Kết thúc'),
      },
    },
    'create.user-task': {
      group: 'activity',
      className: 'bpmn-icon-user-task',
      title: t('Bước 1'),
      action: {
        dragstart: createElement('bpmn:UserTask', 'Bước 1'),
        click: createElement('bpmn:UserTask', 'Bước 1'),
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
