"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DEFAULT_SCHEMA_VERSION = exports.DEFAULT_PROTOCOL_VERSION = void 0;
exports.buildAgreement = buildAgreement;
exports.buildRevision = buildRevision;
exports.buildEvent = buildEvent;
exports.buildDelegationEdge = buildDelegationEdge;
exports.DEFAULT_PROTOCOL_VERSION = "1.0";
exports.DEFAULT_SCHEMA_VERSION = "1.0.0";
function utcNow() {
    return new Date().toISOString().replace(/\.\d{3}Z$/, "Z");
}
function baseArtifact(artifactType, options = {}, createdAt) {
    return {
        artifact_type: artifactType,
        schema_version: options.schemaVersion ?? exports.DEFAULT_SCHEMA_VERSION,
        protocol_version: options.protocolVersion ?? exports.DEFAULT_PROTOCOL_VERSION,
        created_at: createdAt ?? utcNow(),
    };
}
function buildAgreement(agreementId, createdAt, options = {}) {
    return {
        ...baseArtifact("agreement_v1", options, createdAt),
        agreement_id: agreementId,
    };
}
function buildRevision(agreementId, revisionId, createdAt, options = {}) {
    return {
        ...baseArtifact("revision_v1", options, createdAt),
        agreement_id: agreementId,
        revision_id: revisionId,
    };
}
function buildEvent(agreementId, revisionId, eventId, eventType = "REVISION_ACTIVATED", createdAt, options = {}) {
    return {
        ...baseArtifact("event_v1", options, createdAt),
        agreement_id: agreementId,
        revision_id: revisionId,
        event_id: eventId,
        event_type: eventType,
    };
}
function buildDelegationEdge(agreementId, revisionId, edgeId, parentRevisionId, childAgreementId, childRevisionId, parentSubjectRef, childSubjectRef, createdAt, options = {}) {
    return {
        ...baseArtifact("delegation_edge_v1", options, createdAt),
        agreement_id: agreementId,
        revision_id: revisionId,
        edge_id: edgeId,
        parent_revision_id: parentRevisionId,
        child_agreement_id: childAgreementId,
        child_revision_id: childRevisionId,
        parent_subject_ref: parentSubjectRef,
        child_subject_ref: childSubjectRef,
    };
}
