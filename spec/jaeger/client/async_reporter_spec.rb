require 'spec_helper'

RSpec.describe Jaeger::Client::AsyncReporter do
  let(:reporter) { described_class.new(sender, 1) }
  let(:sender) { spy }
  let(:operation_name) { 'op-name' }

  before { allow(Thread).to receive(:new) }

  describe '#report' do
    let(:context) do
      Jaeger::Client::SpanContext.new(
        trace_id: Jaeger::Client::TraceId.generate,
        span_id: Jaeger::Client::TraceId.generate,
        flags: flags
      )
    end
    let(:span) { Jaeger::Client::Span.new(context, operation_name, reporter) }

    context 'when span has debug mode enabled' do
      let(:flags) { Jaeger::Client::SpanContext::Flags::DEBUG }

      it 'buffers the span' do
        reporter.report(span)
        reporter.flush
        expect(sender).to have_received(:send_spans).once
      end
    end

    context 'when span is sampled' do
      let(:flags) { Jaeger::Client::SpanContext::Flags::SAMPLED }

      it 'buffers the span' do
        reporter.report(span)
        reporter.flush
        expect(sender).to have_received(:send_spans).once
      end
    end

    context 'when span does not have debug mode nor is sampled' do
      let(:flags) { Jaeger::Client::SpanContext::Flags::NONE }

      it 'does not buffer the span' do
        reporter.report(span)
        reporter.flush
        expect(sender).not_to have_received(:send_spans)
      end
    end
  end
end
