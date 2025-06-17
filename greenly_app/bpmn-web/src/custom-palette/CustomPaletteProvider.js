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
        ...options,
      })
      if (defaultName) {
        shape.businessObject.name = defaultName
      }
      create.start(event, shape)
    }
  }
  const entries = {
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
        dragstart: createElement('bpmn:EndEvent', {}, 'Kết thúc'),
        click: createElement('bpmn:EndEvent', {}, 'Kết thúc'),
      },
    },
  }
  const customSteps = ['Bước 1', 'Bước 2', 'Bước 3']
  customSteps.forEach((step, index) => {
    const id = `create.user-task-${index + 1}`
    entries[id] = {
      group: 'activity',
      className: 'bpmn-icon-user-task',
      title: t(step),
      action: {
        dragstart: createElement('bpmn:UserTask', {}, step),
        click: createElement('bpmn:UserTask', {}, step),
      },
    }
  })
  return {
    ...entries,
    // 'create.sequence-flow': {
    //   group: 'connect',
    //   className: 'bpmn-icon-connection-multi',
    //   title: t('Kết nối'),
    //   action: {
    //     dragstart: createElement('bpmn:SequenceFlow'),
    //     click: createElement('bpmn:SequenceFlow'),
    //   },
    // },
  }
}
