import { describe, it, expect } from '@jest/globals';
import { TotemInvalidOrNotFound } from '../src/Exception.js';

describe('TotemInvalidOrNotFound Exception', () => {
  it('should create an instance with correct message', () => {
    const exception = new TotemInvalidOrNotFound();

    expect(exception).toBeInstanceOf(Error);
    expect(exception).toBeInstanceOf(TotemInvalidOrNotFound);
    expect(exception.message).toBe('Totem invalid or not found');
    expect(exception.name).toBe('TotemInvalidOrNotFound');
  });

  it('should be throwable', () => {
    expect(() => {
      throw new TotemInvalidOrNotFound();
    }).toThrow('Totem invalid or not found');
  });

  it('should be catchable as Error', () => {
    try {
      throw new TotemInvalidOrNotFound();
    } catch (error) {
      expect(error).toBeInstanceOf(Error);
      expect(error).toBeInstanceOf(TotemInvalidOrNotFound);
      expect(error.message).toBe('Totem invalid or not found');
    }
  });
});
