import { Component, type ReactNode } from 'react';

type P = { children: ReactNode };
type S = { hasError: boolean; msg?: string };

export default class ErrorBoundary extends Component<P, S> {
  state: S = { hasError: false };
  static getDerivedStateFromError(err: Error): S {
    return { hasError: true, msg: String((err as any)?.message || err) };
  }
  render() {
    if (this.state.hasError) {
      return (
        <div role="alert" aria-live="assertive" style={{ background: '#fee', padding: 12, border: '1px solid #f88' }}>
          <strong>Something went wrong.</strong>
          <div>{this.state.msg}</div>
          <button onClick={() => location.reload()}>Reload</button>
        </div>
      );
    }
    return this.props.children;
  }
}
