.. _ai_governance:

=========================================
AI governance and attribution (local use)
=========================================

Purpose
-------

This repository includes a documentation-only AI governance layer designed to:

* Keep kernel runtime behavior unchanged.
* Preserve upstream compatibility by avoiding core execution logic changes.
* Require explicit human and AI attribution in commit metadata.

Scope
-----

This governance layer applies to local development workflows and contribution
process documentation only. It does not modify kernel execution paths,
subsystems, Kconfig behavior, or build logic.

Required commit trailers
------------------------

Commits must include both trailers:

* ``Signed-off-by:`` (Developer Certificate of Origin flow)
* ``Assisted-by:`` (AI/system assistance attribution)

Example::

   Signed-off-by: Jane Developer <jane@example.com>
   Assisted-by: Codex (GPT-5.3-Codex, OpenAI)

Pre-commit policy hook
----------------------

A local Git hook is provided at:

* ``scripts/git-hooks/pre-commit-ai-attribution.sh``

Install it in your local clone:

.. code-block:: bash

   mkdir -p .git/hooks
   cp scripts/git-hooks/pre-commit-ai-attribution.sh .git/hooks/pre-commit
   chmod +x .git/hooks/pre-commit

Commit template
---------------

An example commit template is available at:

* ``Documentation/process/ai-attribution-commit-template.txt``

You may enable it locally:

.. code-block:: bash

   git config commit.template Documentation/process/ai-attribution-commit-template.txt

Compliance checklist
--------------------

Before sending patches, verify:

* No kernel runtime files were changed for governance-only updates.
* Commit message contains both required trailers.
* Local hook is executable and passing.

Rationale
---------

This approach introduces AI attribution and governance controls through
process artifacts (documentation, hooks, and templates) only, so it remains
safe for upstream synchronization and does not alter kernel semantics.
