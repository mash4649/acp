export const DEFAULT_PROTOCOL_VERSION = "1.0";
export const DEFAULT_SCHEMA_VERSION = "1.0.0";

export interface BuildOptions {
  schemaVersion?: string;
  protocolVersion?: string;
}

export interface AgreementArtifact {
  artifact_type: "agreement_v1";
  schema_version: string;
  protocol_version: string;
  agreement_id: string;
  created_at: string;
}

export interface RevisionArtifact {
  artifact_type: "revision_v1";
  schema_version: string;
  protocol_version: string;
  agreement_id: string;
  revision_id: string;
  created_at: string;
}

export interface EventArtifact {
  artifact_type: "event_v1";
  schema_version: string;
  protocol_version: string;
  agreement_id: string;
  revision_id: string;
  event_id: string;
  event_type: string;
  created_at: string;
}

export interface DelegationEdgeArtifact {
  artifact_type: "delegation_edge_v1";
  schema_version: string;
  protocol_version: string;
  agreement_id: string;
  revision_id: string;
  edge_id: string;
  parent_revision_id: string;
  child_agreement_id: string;
  child_revision_id: string;
  parent_subject_ref: string;
  child_subject_ref: string;
  created_at: string;
}

function utcNow(): string {
  return new Date().toISOString().replace(/\.\d{3}Z$/, "Z");
}

function baseArtifact<TArtifactType extends string>(
  artifactType: TArtifactType,
  options: BuildOptions = {},
  createdAt?: string,
): {
  artifact_type: TArtifactType;
  schema_version: string;
  protocol_version: string;
  created_at: string;
} {
  return {
    artifact_type: artifactType,
    schema_version: options.schemaVersion ?? DEFAULT_SCHEMA_VERSION,
    protocol_version: options.protocolVersion ?? DEFAULT_PROTOCOL_VERSION,
    created_at: createdAt ?? utcNow(),
  };
}

export function buildAgreement(
  agreementId: string,
  createdAt?: string,
  options: BuildOptions = {},
): AgreementArtifact {
  return {
    ...baseArtifact("agreement_v1", options, createdAt),
    agreement_id: agreementId,
  };
}

export function buildRevision(
  agreementId: string,
  revisionId: string,
  createdAt?: string,
  options: BuildOptions = {},
): RevisionArtifact {
  return {
    ...baseArtifact("revision_v1", options, createdAt),
    agreement_id: agreementId,
    revision_id: revisionId,
  };
}

export function buildEvent(
  agreementId: string,
  revisionId: string,
  eventId: string,
  eventType = "REVISION_ACTIVATED",
  createdAt?: string,
  options: BuildOptions = {},
): EventArtifact {
  return {
    ...baseArtifact("event_v1", options, createdAt),
    agreement_id: agreementId,
    revision_id: revisionId,
    event_id: eventId,
    event_type: eventType,
  };
}

export function buildDelegationEdge(
  agreementId: string,
  revisionId: string,
  edgeId: string,
  parentRevisionId: string,
  childAgreementId: string,
  childRevisionId: string,
  parentSubjectRef: string,
  childSubjectRef: string,
  createdAt?: string,
  options: BuildOptions = {},
): DelegationEdgeArtifact {
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
