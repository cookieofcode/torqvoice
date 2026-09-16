import { readFileSync } from 'fs'
import { resolve } from 'path'
import { describe, expect, it } from 'vitest'
import {
  ALL_THEME_CLASSES,
  THEMES,
  THEME_IDS,
  getThemeClasses,
  getThemeMode,
  isThemeId,
} from '@/lib/themes'

describe('theme registry', () => {
  it('registers purple as a light preset and violet as a dark preset', () => {
    expect(isThemeId('purple')).toBe(true)
    expect(isThemeId('violet')).toBe(true)
    expect(getThemeMode('purple')).toBe('light')
    expect(getThemeMode('violet')).toBe('dark')
    expect(getThemeClasses('purple')).toEqual(['light', 'theme-purple'])
    expect(getThemeClasses('violet')).toEqual(['dark', 'theme-violet'])
    expect(ALL_THEME_CLASSES).toContain('theme-purple')
    expect(ALL_THEME_CLASSES).toContain('theme-violet')
  })

  it('registers pink as a light preset and rose as a dark preset', () => {
    expect(isThemeId('pink')).toBe(true)
    expect(isThemeId('rose')).toBe(true)
    expect(getThemeMode('pink')).toBe('light')
    expect(getThemeMode('rose')).toBe('dark')
    expect(getThemeClasses('pink')).toEqual(['light', 'theme-pink'])
    expect(getThemeClasses('rose')).toEqual(['dark', 'theme-rose'])
    expect(ALL_THEME_CLASSES).toContain('theme-pink')
    expect(ALL_THEME_CLASSES).toContain('theme-rose')
  })

  it('keeps base light and dark as mode-only classes', () => {
    expect(getThemeClasses('light')).toEqual(['light'])
    expect(getThemeClasses('dark')).toEqual(['dark'])
  })

  it('keeps the pre-hydration class map in sync with THEMES', () => {
    const layout = readFileSync(resolve(process.cwd(), 'src/app/layout.tsx'), 'utf8')
    const match = layout.match(/var M=\{([^}]+)\}/)
    expect(match).toBeTruthy()
    const map: Record<string, string> = {}
    for (const pair of match![1].split(',')) {
      const [id, mode] = pair.split(':').map((part) => part.replaceAll("'", '').trim())
      map[id] = mode
    }
    for (const theme of THEMES) {
      expect(map[theme.id], `FOUC map missing ${theme.id}`).toBe(theme.mode)
    }
    expect(THEME_IDS).toContain('pink')
    expect(THEME_IDS).toContain('rose')
  })

  it('declares CSS custom properties for every preset', () => {
    const css = readFileSync(resolve(process.cwd(), 'src/app/globals.css'), 'utf8')
    for (const theme of THEMES) {
      if (theme.id === theme.mode) continue
      expect(css, `globals.css missing .theme-${theme.id}`).toContain(`.theme-${theme.id} {`)
    }
  })
})
