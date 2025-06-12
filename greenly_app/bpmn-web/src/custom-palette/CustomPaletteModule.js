// CustomPaletteModule.js

import CustomPaletteProvider from './CustomPaletteProvider'

export default {
    __init__: ['customPaletteProvider'],
    paletteProvider: ['type', CustomPaletteProvider], // 👈 ghi đè
    customPaletteProvider: ['type', CustomPaletteProvider]
}
