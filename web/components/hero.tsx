export function Hero() {
  return (
    <section className="hero relative isolate mx-auto mb-12 max-w-2xl text-center">
      <div aria-hidden className="hero-bg">
        <div className="hero-grid" />
        <div className="hero-orb hero-orb-a" />
        <div className="hero-orb hero-orb-b" />
      </div>
      <p className="hero-eyebrow mb-2 text-xs font-medium uppercase tracking-[0.18em] text-accent">
        tfbox / aws
      </p>
      <h1 className="hero-title text-balance text-3xl font-semibold tracking-tight sm:text-4xl">
        Production-grade Terraform modules for AWS.
      </h1>
      <p className="hero-sub mx-auto mt-3 max-w-xl text-sm text-muted sm:text-base">
        Find ready-to-use modules across the AWS stack — fully documented inputs and outputs, dependency
        diagrams, and copy-paste examples, generated from the source{" "}
        <code className="font-mono text-text">.tf</code> files and always in sync.
      </p>
    </section>
  );
}
