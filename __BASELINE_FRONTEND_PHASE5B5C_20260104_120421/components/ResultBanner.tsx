import React from 'react';

type Props = { kind: 'ok' | 'err' | null; text?: string };
export default function ResultBanner({ kind, text }: Props) {
  if (!kind) return null;
  const bg = kind === 'ok' ? '#e6ffed' : '#ffe6e6';
  const fg = kind === 'ok' ? '#046d1a' : '#8a1010';
  return (
    <div style={{
      background: bg, color: fg, padding: 10, borderRadius: 8,
      border: `1px solid ${fg}33`, marginBottom: 12
    }}>
      {text}
    </div>
  );
}
