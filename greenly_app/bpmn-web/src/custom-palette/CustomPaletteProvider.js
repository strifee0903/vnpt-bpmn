// CustomPaletteProvider.js

export default function CustomPaletteProvider(create, elementFactory, palette, translate) {
    this._create = create
    this._elementFactory = elementFactory
    this._translate = translate

    palette.registerProvider(this)
}

CustomPaletteProvider.$inject = [
    'create',
    'elementFactory',
    'palette',
    'translate'
]

CustomPaletteProvider.prototype.getPaletteEntries = function () {
    const {
        _create: create,
        _elementFactory: elementFactory,
        _translate: t
    } = this

    function createStartEvent(event) {
        const shape = elementFactory.createShape({ type: 'bpmn:StartEvent' })
        create.start(event, shape)
    }

    return {
        'create.start-event': {
            group: 'event',
            className: 'bpmn-icon-start-event-none',
            title: t('Bắt đầu'),
            action: {
                dragstart: createStartEvent,
                click: createStartEvent
            }
        }
    }
}
