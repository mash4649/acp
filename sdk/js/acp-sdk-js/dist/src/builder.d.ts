export declare const DEFAULT_PROTOCOL_VERSION = "1.0";
export declare const DEFAULT_SCHEMA_VERSION = "1.0.0";
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
export declare function buildAgreement(agreementId: string, createdAt?: string, options?: BuildOptions): AgreementArtifact;
export declare function buildRevision(agreementId: string, revisionId: string, createdAt?: string, options?: BuildOptions): RevisionArtifact;
export declare function buildEvent(agreementId: string, revisionId: string, eventId: string, eventType?: string, createdAt?: string, options?: BuildOptions): EventArtifact;
export declare function buildDelegationEdge(agreementId: string, revisionId: string, edgeId: string, parentRevisionId: string, childAgreementId: string, childRevisionId: string, parentSubjectRef: string, childSubjectRef: string, createdAt?: string, options?: BuildOptions): DelegationEdgeArtifact;
