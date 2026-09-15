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
    expect(THEME_IDS).toContain('purple')
    expect(THEME_IDS).toContain('violet')
  })
})
