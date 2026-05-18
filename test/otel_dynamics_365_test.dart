// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_dynamics_365/otel_dynamics_365.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_dynamics_365-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('webApi.retrieveMultiple records entity + page + returned', () async {
    await tracedDynamics365<String>(
      operation: 'webApi.retrieveMultiple',
      invoke: () async => const Dynamics365CallResult(
        value: 'ok',
        result: Dynamics365Result(
          surface: 'web_api',
          orgUrl: 'contoso.crm.dynamics.com',
          environment: 'prod',
          entitySetName: 'accounts',
          entityLogicalName: 'account',
          action: 'retrieveMultiple',
          queryPageSize: 50,
          queryReturnedCount: 50,
        ),
      ),
    );
    final a =
        attrsOf(spans.findSpanByName('dynamics_365 webApi.retrieveMultiple')!);
    expect(a['dynamics_365.entity.logical_name'], 'account');
    expect(a['dynamics_365.query.returned_count'], 50);
  });

  test('batch records request + changeset counts', () async {
    await tracedDynamics365<String>(
      operation: 'webApi.batch',
      invoke: () async => const Dynamics365CallResult(
        value: 'ok',
        result: Dynamics365Result(
          surface: 'web_api',
          action: 'batch',
          batchRequestCount: 24,
          batchChangesetCount: 3,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('dynamics_365 webApi.batch')!);
    expect(a['dynamics_365.batch.request_count'], 24);
    expect(a['dynamics_365.batch.changeset_count'], 3);
  });

  test('Failed workflow sets span error', () async {
    await tracedDynamics365<String>(
      operation: 'webApi.executeAction',
      invoke: () async => const Dynamics365CallResult(
        value: 'ok',
        result: Dynamics365Result(
          workflowName: 'lead-routing',
          workflowStage: 'Failed',
        ),
      ),
    );
    expect(
      spans.findSpanByName('dynamics_365 webApi.executeAction')!.status,
      SpanStatusCode.Error,
    );
  });

  test('error code sets span error', () async {
    await tracedDynamics365<String>(
      operation: 'webApi.create',
      invoke: () async => const Dynamics365CallResult(
        value: 'ok',
        result: Dynamics365Result(
          errorCode: '0x80048d0c',
          errorMessage: 'Duplicate detected',
          statusCode: 409,
        ),
      ),
    );
    expect(
      spans.findSpanByName('dynamics_365 webApi.create')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutDynamics365InstrumentationAsync(() async {
      await tracedDynamics365<String>(
        operation: 'webApi.whoAmI',
        invoke: () async => const Dynamics365CallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('dynamics_365 '), isEmpty);
  });
}
