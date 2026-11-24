# Clean Architecture

The application uses a feature-first Clean Architecture structure.

## Dependency rule

Dependencies point inward:

`presentation -> domain <- data`

- `domain` contains entities, repository contracts, services contracts, and use cases.
- `data` implements domain contracts and integrates with device or persistence APIs.
- `presentation` contains pages, widgets, and controllers. It calls use cases rather than data implementations.
- `core/di` is the composition root. Concrete implementations are created only there.

## Feature layout

```text
lib/
  core/
    di/
  features/
    auth/
      domain/
    reports/
      domain/
      data/
      presentation/
    visits/
      domain/
  data/                 # temporary demo implementations
  presentation/         # existing screens; migrated incrementally to feature folders
```

The files under `lib/domain/` are compatibility barrels. New code must import the
feature domain files directly. Demo repositories remain replaceable through
`AppDependencies`, allowing a database or remote API implementation without UI
changes.

## State and operations

- Authentication runs through `SignInUser`.
- Visits run through `GetVisits` and `AddVisit`.
- Reports run through `GetReports`, `AddReport`, and `UpdateReport`.
- Report screens use `ReportController` for mutations and notifications.
- PDF platform export is behind the `ReportExporter` domain contract and the
  `PrintingReportExporter` data implementation.
