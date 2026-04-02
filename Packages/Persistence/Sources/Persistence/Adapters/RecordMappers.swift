import Foundation
import DomainModels

// MARK: - ImportSessionRecord <-> ImportSession

extension ImportSessionRecord {
    // TODO: Agent 2 — implement mapping from DomainModels.ImportSession
    public init(from domain: ImportSession) {
        self.id = domain.id.uuidString
        self.createdAt = domain.createdAt
        self.updatedAt = domain.updatedAt
        self.sourceType = domain.sourceType.rawValue
        self.sourceBookmarkData = domain.sourceBookmarkData
        self.displayName = domain.displayName
        self.status = domain.status.rawValue
        self.phase = domain.phase.rawValue
        self.importMode = domain.importMode.rawValue
        self.healthSummarySnapshot = domain.healthSummarySnapshot
        self.startedAt = domain.startedAt
        self.completedAt = domain.completedAt
        self.cancelledAt = domain.cancelledAt
        self.totalDiscoveredCount = domain.totalDiscoveredCount
        self.plannedImportCount = domain.plannedImportCount
        self.successfulImportCount = domain.successfulImportCount
        self.skippedCount = domain.skippedCount
        self.failureCount = domain.failureCount
        self.requiresUserAction = domain.requiresUserAction
        self.cleanupState = domain.cleanupState.rawValue
    }

    // TODO: Agent 2 — validate enum raw values, handle failures gracefully
    public func toDomain() -> ImportSession? {
        guard
            let uuid = UUID(uuidString: id),
            let sourceType = SourceType(rawValue: sourceType),
            let status = ImportSessionStatus(rawValue: status),
            let phase = ImportPhase(rawValue: phase),
            let importMode = ImportMode(rawValue: importMode),
            let cleanupState = CleanupState(rawValue: cleanupState)
        else { return nil }

        return ImportSession(
            id: uuid,
            createdAt: createdAt,
            updatedAt: updatedAt,
            sourceType: sourceType,
            sourceBookmarkData: sourceBookmarkData,
            displayName: displayName,
            status: status,
            phase: phase,
            importMode: importMode,
            healthSummarySnapshot: healthSummarySnapshot,
            startedAt: startedAt,
            completedAt: completedAt,
            cancelledAt: cancelledAt,
            totalDiscoveredCount: totalDiscoveredCount,
            plannedImportCount: plannedImportCount,
            successfulImportCount: successfulImportCount,
            skippedCount: skippedCount,
            failureCount: failureCount,
            requiresUserAction: requiresUserAction,
            cleanupState: cleanupState
        )
    }
}

// MARK: - ParsedSnapRecordRow <-> ParsedSnapRecord

extension ParsedSnapRecordRow {
    // TODO: Agent 2 — implement mapping from DomainModels.ParsedSnapRecord
    public init(from domain: ParsedSnapRecord) {
        self.id = domain.id.uuidString
        self.sessionId = domain.sessionId.uuidString
        self.sourceRecordIdentifier = domain.sourceRecordIdentifier
        self.relativeMediaPath = domain.relativeMediaPath
        self.mediaType = domain.mediaType.rawValue
        self.snapchatTimestamp = domain.snapchatTimestamp
        self.embeddedTimestamp = domain.embeddedTimestamp
        self.normalizedTimestamp = domain.normalizedTimestamp
        self.locationLatitude = domain.locationLatitude
        self.locationLongitude = domain.locationLongitude
        self.locationSource = domain.locationSource
        self.metadataConfidence = domain.metadataConfidence.rawValue
        self.rawChecksumHint = domain.rawChecksumHint
        self.validationStatus = domain.validationStatus.rawValue
    }

    // TODO: Agent 2 — validate enum raw values, handle failures gracefully
    public func toDomain() -> ParsedSnapRecord? {
        guard
            let uuid = UUID(uuidString: id),
            let sessionUUID = UUID(uuidString: sessionId),
            let mediaType = MediaType(rawValue: mediaType),
            let confidence = MetadataConfidence(rawValue: metadataConfidence),
            let validation = ValidationStatus(rawValue: validationStatus)
        else { return nil }

        return ParsedSnapRecord(
            id: uuid,
            sessionId: sessionUUID,
            sourceRecordIdentifier: sourceRecordIdentifier,
            relativeMediaPath: relativeMediaPath,
            mediaType: mediaType,
            snapchatTimestamp: snapchatTimestamp,
            embeddedTimestamp: embeddedTimestamp,
            normalizedTimestamp: normalizedTimestamp,
            locationLatitude: locationLatitude,
            locationLongitude: locationLongitude,
            locationSource: locationSource,
            metadataConfidence: confidence,
            rawChecksumHint: rawChecksumHint,
            validationStatus: validation
        )
    }
}

// MARK: - ImportAssetRecord <-> ImportAsset

extension ImportAssetRecord {
    // TODO: Agent 2 — implement mapping from DomainModels.ImportAsset
    public init(from domain: ImportAsset) {
        self.id = domain.id.uuidString
        self.sessionId = domain.sessionId.uuidString
        self.parsedRecordId = domain.parsedRecordId.uuidString
        self.resolvedSourcePath = domain.resolvedSourcePath
        self.workingFilePath = domain.workingFilePath
        self.mediaType = domain.mediaType.rawValue
        self.normalizedTimestamp = domain.normalizedTimestamp
        self.locationLatitude = domain.locationLatitude
        self.locationLongitude = domain.locationLongitude
        self.confidence = domain.confidence.rawValue
        self.contentHash = domain.contentHash
        self.byteSize = domain.byteSize
        self.duration = domain.duration
        self.pixelWidth = domain.pixelWidth
        self.pixelHeight = domain.pixelHeight
        self.importStatus = domain.importStatus.rawValue
        self.failureReason = domain.failureReason?.rawValue
        self.photosLocalIdentifier = domain.photosLocalIdentifier
    }

    // TODO: Agent 2 — validate enum raw values, handle failures gracefully
    public func toDomain() -> ImportAsset? {
        guard
            let uuid = UUID(uuidString: id),
            let sessionUUID = UUID(uuidString: sessionId),
            let parsedRecordUUID = UUID(uuidString: parsedRecordId),
            let mediaType = MediaType(rawValue: mediaType),
            let confidence = MetadataConfidence(rawValue: confidence),
            let status = ImportAssetStatus(rawValue: importStatus)
        else { return nil }

        return ImportAsset(
            id: uuid,
            sessionId: sessionUUID,
            parsedRecordId: parsedRecordUUID,
            resolvedSourcePath: resolvedSourcePath,
            workingFilePath: workingFilePath,
            mediaType: mediaType,
            normalizedTimestamp: normalizedTimestamp,
            locationLatitude: locationLatitude,
            locationLongitude: locationLongitude,
            confidence: confidence,
            contentHash: contentHash,
            byteSize: byteSize,
            duration: duration,
            pixelWidth: pixelWidth,
            pixelHeight: pixelHeight,
            importStatus: status,
            failureReason: failureReason.flatMap { ImportFailureReason(rawValue: $0) },
            photosLocalIdentifier: photosLocalIdentifier
        )
    }
}

// MARK: - LibraryAssetCacheRecord <-> LibraryAssetReference

extension LibraryAssetCacheRecord {
    // TODO: Agent 2 — implement mapping from DomainModels.LibraryAssetReference
    public init(from domain: LibraryAssetReference) {
        self.id = domain.id.uuidString
        self.photosLocalIdentifier = domain.photosLocalIdentifier
        self.creationDate = domain.creationDate
        self.mediaType = domain.mediaType.rawValue
        self.duration = domain.duration
        self.pixelWidth = domain.pixelWidth
        self.pixelHeight = domain.pixelHeight
        self.byteSizeHint = domain.byteSizeHint
        self.fingerprint = domain.fingerprint
        self.albumMembershipHint = domain.albumMembershipHint
    }

    // TODO: Agent 2 — validate enum raw values, handle failures gracefully
    public func toDomain() -> LibraryAssetReference? {
        guard
            let uuid = UUID(uuidString: id),
            let mediaType = MediaType(rawValue: mediaType)
        else { return nil }

        return LibraryAssetReference(
            id: uuid,
            photosLocalIdentifier: photosLocalIdentifier,
            creationDate: creationDate,
            mediaType: mediaType,
            duration: duration,
            pixelWidth: pixelWidth,
            pixelHeight: pixelHeight,
            byteSizeHint: byteSizeHint,
            fingerprint: fingerprint,
            albumMembershipHint: albumMembershipHint
        )
    }
}

// MARK: - DuplicateCandidateRecord <-> DuplicateCandidate

extension DuplicateCandidateRecord {
    // TODO: Agent 2 — implement mapping from DomainModels.DuplicateCandidate
    public init(from domain: DuplicateCandidate) {
        self.id = domain.id.uuidString
        self.sessionId = domain.sessionId.uuidString
        self.importAssetId = domain.importAssetId.uuidString
        self.libraryAssetLocalIdentifier = domain.libraryAssetLocalIdentifier
        self.confidence = domain.confidence.rawValue
        self.reasonCode = domain.reasonCode.rawValue
        self.score = domain.score
        self.reviewStatus = domain.reviewStatus.rawValue
        self.userDecision = domain.userDecision?.rawValue
        self.createdAt = domain.createdAt
        self.resolvedAt = domain.resolvedAt
    }

    // TODO: Agent 2 — validate enum raw values, handle failures gracefully
    public func toDomain() -> DuplicateCandidate? {
        guard
            let uuid = UUID(uuidString: id),
            let sessionUUID = UUID(uuidString: sessionId),
            let assetUUID = UUID(uuidString: importAssetId),
            let confidence = DuplicateConfidence(rawValue: confidence),
            let reason = DuplicateReasonCode(rawValue: reasonCode),
            let review = ReviewStatus(rawValue: reviewStatus)
        else { return nil }

        return DuplicateCandidate(
            id: uuid,
            sessionId: sessionUUID,
            importAssetId: assetUUID,
            libraryAssetLocalIdentifier: libraryAssetLocalIdentifier,
            confidence: confidence,
            reasonCode: reason,
            score: score,
            reviewStatus: review,
            userDecision: userDecision.flatMap { DuplicateReviewDecision(rawValue: $0) },
            createdAt: createdAt,
            resolvedAt: resolvedAt
        )
    }
}

// MARK: - ImportFailureRecord <-> ImportFailure

extension ImportFailureRecord {
    // TODO: Agent 2 — implement mapping from DomainModels.ImportFailure
    public init(from domain: ImportFailure) {
        self.id = domain.id.uuidString
        self.sessionId = domain.sessionId.uuidString
        self.importAssetId = domain.importAssetId?.uuidString
        self.phase = domain.phase
        self.reason = domain.reason.rawValue
        self.detail = domain.detail
        self.retryEligible = domain.retryEligible
        self.createdAt = domain.createdAt
    }

    // TODO: Agent 2 — validate enum raw values, handle failures gracefully
    public func toDomain() -> ImportFailure? {
        guard
            let uuid = UUID(uuidString: id),
            let sessionUUID = UUID(uuidString: sessionId),
            let reason = ImportFailureReason(rawValue: reason)
        else { return nil }

        return ImportFailure(
            id: uuid,
            sessionId: sessionUUID,
            importAssetId: importAssetId.flatMap { UUID(uuidString: $0) },
            phase: phase,
            reason: reason,
            detail: detail,
            retryEligible: retryEligible,
            createdAt: createdAt
        )
    }
}

// MARK: - DiagnosticEventRecord <-> DiagnosticEvent

extension DiagnosticEventRecord {
    // TODO: Agent 2 — implement mapping from DomainModels.DiagnosticEvent
    public init(from domain: DiagnosticEvent) {
        self.id = domain.id.uuidString
        self.sessionId = domain.sessionId?.uuidString
        self.timestamp = domain.timestamp
        self.category = domain.category
        self.message = domain.message
        self.severity = domain.severity.rawValue
        if let meta = domain.metadata {
            self.metadataJson = try? String(
                data: JSONEncoder().encode(meta),
                encoding: .utf8
            )
        } else {
            self.metadataJson = nil
        }
    }

    // TODO: Agent 2 — validate enum raw values, handle failures gracefully
    public func toDomain() -> DiagnosticEvent? {
        guard
            let uuid = UUID(uuidString: id),
            let severity = DiagnosticSeverity(rawValue: severity)
        else { return nil }

        var metadata: [String: String]?
        if let json = metadataJson, let data = json.data(using: .utf8) {
            metadata = try? JSONDecoder().decode([String: String].self, from: data)
        }

        return DiagnosticEvent(
            id: uuid,
            sessionId: sessionId.flatMap { UUID(uuidString: $0) },
            timestamp: timestamp,
            category: category,
            message: message,
            severity: severity,
            metadata: metadata
        )
    }
}
