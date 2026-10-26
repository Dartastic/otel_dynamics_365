// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_dynamics_365_suppression.dart';

const _tracerName = 'dartastic_otel_libs_dynamics_365';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

class Dynamics365Result {
  /// Creates a result.
  const Dynamics365Result({
    this.surface,
    this.orgUrl,
    this.tenantId,
    this.environment,
    this.appModule,
    this.entitySetName,
    this.entityLogicalName,
    this.recordId,
    this.action,
    this.batchRequestCount,
    this.batchChangesetCount,
    this.fetchXml,
    this.queryPageSize,
    this.queryReturnedCount,
    this.fetchedRowCount,
    this.affectedRowCount,
    this.solutionUniqueName,
    this.workflowName,
    this.workflowStage,
    this.pluginStage,
    this.businessUnit,
    this.errorCode,
    this.errorMessage,
    this.statusCode,
  });

  /// `web_api`, `organization_service`, `customer_engagement`,
  /// `business_central`, `finance_operations`, `field_service`,
  /// `customer_insights`, `marketing`, `commerce`, `supply_chain`,
  /// `human_resources`, `intelligent_order_management`.
  final String? surface;

  /// `<org>.crm.dynamics.com` or finance/business-central host.
  final String? orgUrl;
  final String? tenantId;

  /// `prod`, `sandbox`, `developer`, `support`, `trial`.
  final String? environment;

  final String? appModule;

  /// OData entity set name (`accounts`, `contacts`, `incidents`).
  final String? entitySetName;

  /// CRM entity logical name (`account`, `contact`, `incident`).
  final String? entityLogicalName;

  /// CRM record `id` (GUID).
  final String? recordId;

  /// `create`, `retrieve`, `update`, `delete`, `upsert`, `associate`,
  /// `disassociate`, `executeAction`, `executeFunction`, `batch`,
  /// `whoAmI`, `assign`, `retrieveMultiple`.
  final String? action;

  /// Number of requests in a $batch.
  final int? batchRequestCount;

  /// Number of changesets in a $batch.
  final int? batchChangesetCount;

  /// FetchXML query length (we record length, not the query).
  final int? fetchXml;

  /// `$top` / page size used.
  final int? queryPageSize;

  /// Rows returned by the OData / Web API call.
  final int? queryReturnedCount;
  final int? fetchedRowCount;
  final int? affectedRowCount;

  final String? solutionUniqueName;

  // ── Workflows + plugins ───────────────────────────────────────
  final String? workflowName;

  /// `Pending`, `In Progress`, `Succeeded`, `Failed`, `Cancelled`,
  /// `Waiting`.
  final String? workflowStage;

  /// `PreValidation`, `PreOperation`, `MainOperation`, `PostOperation`.
  final String? pluginStage;

  final String? businessUnit;

  /// Dataverse error code (e.g. `0x80040217` not found,
  /// `0x80048d0c` duplicate detected, `0x80060888` plugin throw,
  /// `0x80072322` size limit, `0x80061011` privilege denied).
  final String? errorCode;
  final String? errorMessage;
  final int? statusCode;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class Dynamics365CallResult<T> {
  /// Creates a call result.
  const Dynamics365CallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final Dynamics365Result? result;
}

/// Wraps a Dynamics 365 call in a CLIENT span. [operation] is one of
/// `webApi.create`, `webApi.retrieve`, `webApi.retrieveMultiple`,
/// `webApi.update`, `webApi.delete`, `webApi.upsert`, `webApi.batch`,
/// `webApi.associate`, `webApi.disassociate`, `webApi.executeAction`,
/// `webApi.executeFunction`, `webApi.fetchXml`,
/// `organizationService.create`, `organizationService.retrieve`,
/// `organizationService.update`, `organizationService.delete`,
/// `organizationService.execute`, `customerInsights.segment.list`,
/// `customerInsights.profile.get`, `marketing.journey.start`,
/// `marketing.journey.stop`, `marketing.email.send`,
/// `commerce.order.create`, `commerce.order.confirm`,
/// `commerce.return.process`, `supplyChain.inventory.adjust`,
/// `supplyChain.purchase.confirm`, `financeOperations.invoice.post`,
/// `financeOperations.ledger.transaction.create`,
/// `businessCentral.entity.create`, `businessCentral.entity.update`,
/// `humanResources.worker.create`, `humanResources.worker.update`,
/// `fieldService.workOrder.create`, `fieldService.bookable.schedule`,
/// `intelligentOrderManagement.order.orchestrate`.
Future<T> tracedDynamics365<T>({
  required String operation,
  required Future<Dynamics365CallResult<T>> Function() invoke,
}) async {
  if (dynamics365InstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'dynamics_365',
    'rpc.method': operation,
    'dynamics_365.operation': operation,
  };

  final span = _tracer().startSpan(
    'dynamics_365 $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.surface != null) {
        extras
            .add(OTelAPI.attributeString('dynamics_365.surface', res.surface!));
      }
      if (res.orgUrl != null) {
        extras
            .add(OTelAPI.attributeString('dynamics_365.org.url', res.orgUrl!));
      }
      if (res.tenantId != null) {
        extras.add(OTelAPI.attributeString(
          'dynamics_365.tenant.id',
          res.tenantId!,
        ));
      }
      if (res.environment != null) {
        extras.add(OTelAPI.attributeString(
          'dynamics_365.environment',
          res.environment!,
        ));
      }
      if (res.appModule != null) {
        extras.add(OTelAPI.attributeString(
          'dynamics_365.app_module',
          res.appModule!,
        ));
      }
      if (res.entitySetName != null) {
        extras.add(OTelAPI.attributeString(
          'dynamics_365.entity.set_name',
          res.entitySetName!,
        ));
      }
      if (res.entityLogicalName != null) {
        extras.add(OTelAPI.attributeString(
          'dynamics_365.entity.logical_name',
          res.entityLogicalName!,
        ));
      }
      if (res.recordId != null) {
        extras.add(OTelAPI.attributeString(
          'dynamics_365.record.id',
          res.recordId!,
        ));
      }
      if (res.action != null) {
        extras.add(OTelAPI.attributeString('dynamics_365.action', res.action!));
      }
      if (res.batchRequestCount != null) {
        extras.add(OTelAPI.attributeInt(
          'dynamics_365.batch.request_count',
          res.batchRequestCount!,
        ));
      }
      if (res.batchChangesetCount != null) {
        extras.add(OTelAPI.attributeInt(
          'dynamics_365.batch.changeset_count',
          res.batchChangesetCount!,
        ));
      }
      if (res.fetchXml != null) {
        extras.add(OTelAPI.attributeInt(
          'dynamics_365.fetch_xml.length',
          res.fetchXml!,
        ));
      }
      if (res.queryPageSize != null) {
        extras.add(OTelAPI.attributeInt(
          'dynamics_365.query.page_size',
          res.queryPageSize!,
        ));
      }
      if (res.queryReturnedCount != null) {
        extras.add(OTelAPI.attributeInt(
          'dynamics_365.query.returned_count',
          res.queryReturnedCount!,
        ));
      }
      if (res.fetchedRowCount != null) {
        extras.add(OTelAPI.attributeInt(
          'dynamics_365.fetched_row_count',
          res.fetchedRowCount!,
        ));
      }
      if (res.affectedRowCount != null) {
        extras.add(OTelAPI.attributeInt(
          'dynamics_365.affected_row_count',
          res.affectedRowCount!,
        ));
      }
      if (res.solutionUniqueName != null) {
        extras.add(OTelAPI.attributeString(
          'dynamics_365.solution.unique_name',
          res.solutionUniqueName!,
        ));
      }
      if (res.workflowName != null) {
        extras.add(OTelAPI.attributeString(
          'dynamics_365.workflow.name',
          res.workflowName!,
        ));
      }
      if (res.workflowStage != null) {
        extras.add(OTelAPI.attributeString(
          'dynamics_365.workflow.stage',
          res.workflowStage!,
        ));
        if (res.workflowStage == 'Failed') {
          span.setStatus(SpanStatusCode.Error, 'D365 workflow Failed');
        }
      }
      if (res.pluginStage != null) {
        extras.add(OTelAPI.attributeString(
          'dynamics_365.plugin.stage',
          res.pluginStage!,
        ));
      }
      if (res.businessUnit != null) {
        extras.add(OTelAPI.attributeString(
          'dynamics_365.business_unit',
          res.businessUnit!,
        ));
      }
      if (res.errorCode != null) {
        extras.add(OTelAPI.attributeString(
          'dynamics_365.error.code',
          res.errorCode!,
        ));
        span.setStatus(SpanStatusCode.Error, 'D365 ${res.errorCode}');
      }
      if (res.errorMessage != null) {
        extras.add(OTelAPI.attributeString(
          'dynamics_365.error.message',
          res.errorMessage!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTelAPI.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(SpanStatusCode.Error, 'D365 HTTP ${res.statusCode}');
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTelAPI.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
