// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_dynamics_365/otel_dynamics_365.dart';

/// Traces Dynamics 365 calls with OpenTelemetry.
///
/// `otel_dynamics_365` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Dynamics 365 call in
/// [tracedDynamics365]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'dynamics-365-example');

  // Wraps a Dynamics 365 call in a CLIENT span.
  final dynamics365Id = await tracedDynamics365<String>(
    operation: 'commerce.order.create',
    invoke: () async {
      // Make the Dynamics 365 call here, then report what it returned.
      const id = 'dynamics_365_8f3a2c';
      return const Dynamics365CallResult(
          value: id,
          result: Dynamics365Result(
              surface: 'web_api',
              orgUrl: '<org>.crm.dynamics.com',
              tenantId: 'tenant_8f3a2c',
              environment: 'prod',
              appModule: 'example',
              entitySetName: 'accounts',
              entityLogicalName: 'account',
              recordId: 'record_8f3a2c',
              action: 'create',
              batchRequestCount: 3,
              batchChangesetCount: 3,
              fetchXml: 1,
              queryPageSize: 512,
              queryReturnedCount: 3,
              fetchedRowCount: 3,
              affectedRowCount: 3,
              solutionUniqueName: 'example',
              workflowName: 'example',
              workflowStage: 'Pending',
              pluginStage: 'PreValidation',
              businessUnit: 'example',
              errorCode: '0x80040217',
              errorMessage: 'example',
              statusCode: 201));
    },
  );
  OTelLog.info(
      'tracedDynamics365 commerce.order.create returned $dynamics365Id');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutDynamics365InstrumentationAsync.
  await runWithoutDynamics365InstrumentationAsync(
    () => tracedDynamics365<String>(
      operation: 'commerce.order.create',
      invoke: () async {
        const id = 'dynamics_365_8f3a2c';
        return const Dynamics365CallResult(
            value: id,
            result: Dynamics365Result(
                surface: 'web_api',
                orgUrl: '<org>.crm.dynamics.com',
                tenantId: 'tenant_8f3a2c',
                environment: 'prod',
                appModule: 'example',
                entitySetName: 'accounts',
                entityLogicalName: 'account',
                recordId: 'record_8f3a2c',
                action: 'create',
                batchRequestCount: 3,
                batchChangesetCount: 3,
                fetchXml: 1,
                queryPageSize: 512,
                queryReturnedCount: 3,
                fetchedRowCount: 3,
                affectedRowCount: 3,
                solutionUniqueName: 'example',
                workflowName: 'example',
                workflowStage: 'Pending',
                pluginStage: 'PreValidation',
                businessUnit: 'example',
                errorCode: '0x80040217',
                errorMessage: 'example',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
