#!/bin/bash -e

cd $(dirname $0)/../.repo/keycloak

for milestone in $(gh api -X get /repos/keycloak/keycloak-private/milestones -F state=open -q .[].title); do
  echo "=========================================================="
  echo Milestone: $milestone
  echo "=========================================================="

  CVE_IDS=$(gh issue list -S milestone:"$milestone" --json title | jq '.[].title | select(startswith("[CVE-20"))' | cut -d '[' -f 2 | cut -d ']' -f 1)

  ALL_PRS=$(gh pr list -S state:open --json number,title,headRefOid,reviews,isDraft,baseRefName,labels)

  for cve_id in $CVE_IDS; do
    echo "-----------------------------------------"
    echo "$cve_id"
    echo "-----------------------------------------"

    cve_prs=$(echo "$ALL_PRS" | jq '[.[] | select(.title | startswith("'$cve_id'"))] | .[].number')

    for cve_pr in $cve_prs; do
      cve_ref=$(echo "$ALL_PRS" | jq -r '.[] | select(.number == '$cve_pr') | .baseRefName')
      cve_commit=$(echo "$ALL_PRS" | jq -r '.[] | select(.number == '$cve_pr') | .headRefOid')
      cve_labels=$(echo "$ALL_PRS" | jq -r '.[] | select(.number == '$cve_pr') | [.labels[] | .name] | join(", ")')

      echo "PR: https://github.com/keycloak/keycloak-private/pull/$cve_pr, ref: $cve_ref, labels: $cve_labels, commit: $cve_commit"
      echo
      echo -n "Approvals: "
      echo "$ALL_PRS" | jq -r '[ .[] | select(.number == '$cve_pr') | .reviews[] | select(.state == "APPROVED") | .author.login ] | unique | join(", ")'
      echo ""
      gh run list -c $cve_commit
      echo ""

    done


  done
done