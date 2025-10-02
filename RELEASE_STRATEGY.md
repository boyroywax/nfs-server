# NFS Server Release Strategy - Multi-Variant Approach

**Date:** October 2, 2025  
**Decision:** Multi-variant tagging strategy for v1.0.1

---

## Release Strategy

### Variants Overview

We maintain **THREE variants** of the NFS server, each optimized for different use cases:

| Variant | Tag | Size | NFSv4 | Kerberos | Use Case |
|---------|-----|------|-------|----------|----------|
| **Standard** | `1.0.1` (default) | 68.6 MB | ✅ Yes | ✅ Yes | Full features, enterprise |
| **Minimal** | `1.0.1-minimal` | 62.8 MB | ✅ Yes | ✅ Yes | Optimized, full features |
| **Ultra** | `1.0.1-ultra` | 22.7 MB | ❌ No (v3 only) | ❌ No | Maximum optimization |

### Tag Strategy

#### Standard (Default)
```bash
boyroywax/nfs-server:1.0.1          # Semantic version (default)
boyroywax/nfs-server:1.0            # Minor version
boyroywax/nfs-server:1              # Major version
boyroywax/nfs-server:latest         # Latest stable
boyroywax/nfs-server:standard       # Explicit standard
```

**Features:**
- NFSv3 **and** NFSv4 support
- Kerberos/GSS authentication
- Full Python tools (nfsiostat, etc.)
- Bash shell
- All NFS features enabled

**When to use:**
- Need NFSv4 features
- Need Kerberos authentication
- Enterprise environments
- Maximum compatibility required
- Security policies require v4

#### Ultra (Lightweight)
```bash
boyroywax/nfs-server:1.0.1-ultra    # Semantic version ultra
boyroywax/nfs-server:ultra          # Latest ultra
boyroywax/nfs-server:alpine         # Alternative naming
```

**Features:**
- NFSv3 support **only**
- Basic NFS authentication
- No Python (built from source)
- Busybox shell only
- Minimal dependencies

**When to use:**
- Size is critical (CI/CD, edge, IoT)
- NFSv3 is sufficient
- Trusted network (no Kerberos needed)
- Fast image pulls required
- Minimal attack surface desired

#### Minimal (Middle Ground)
```bash
boyroywax/nfs-server:1.0.1-minimal  # Semantic version minimal
```

**Features:**
- NFSv3 and NFSv4 support
- Kerberos/GSS authentication
- Includes Python (package dependencies)
- POSIX shell scripts (no bash)
- Package-level optimization

**When to use:**
- Want smaller size but keep NFSv4
- Need Kerberos support
- Moderate optimization acceptable

---

## Decision Rationale

### Why NOT v2.0.0 for Ultra?

**Semantic Versioning Principles:**
- Major version (2.0.0) implies breaking changes **with new features**
- Ultra is a **feature reduction**, not addition
- v2.0.0 suggests "better than v1" but ultra has **fewer capabilities**
- Would confuse users expecting v2 > v1

### Why NOT Separate Branch?

**Maintenance Issues:**
- Doubles code maintenance effort
- Fragments the community
- Makes issue tracking complex
- Unclear which is "canonical"
- Harder for users to discover options

### Why Multi-Variant Tags? ✅

**Best of Both Worlds:**
- Single codebase, multiple build targets
- Users can choose based on needs
- No breaking changes
- Clear naming conventions
- Easy to maintain
- Follows Docker best practices (alpine, slim, etc.)

---

## Migration Path

### For Existing Users (v1.0.0 → v1.0.1)

**No action required** - Default tag remains full-featured:
```bash
# These all get the standard version
docker pull boyroywax/nfs-server:1.0.1
docker pull boyroywax/nfs-server:latest
docker pull boyroywax/nfs-server:1
```

### For New Users

**Choose based on requirements:**

```bash
# Need NFSv4 or Kerberos? Use standard
docker pull boyroywax/nfs-server:1.0.1

# Size critical? Try ultra first
docker pull boyroywax/nfs-server:1.0.1-ultra

# Want best of both? Use minimal
docker pull boyroywax/nfs-server:1.0.1-minimal
```

### Testing Ultra

Users can easily test ultra without commitment:
```bash
# Test ultra in development
docker run -d \
  --name nfs-test \
  --privileged \
  -p 2049:2049 \
  boyroywax/nfs-server:1.0.1-ultra

# If it works, update production tag
# If not, use standard version
```

---

## Build & Release Process

### 1. Build All Variants

```bash
# Standard (default)
docker build -f Dockerfile \
  -t boyroywax/nfs-server:1.0.1 \
  -t boyroywax/nfs-server:1.0 \
  -t boyroywax/nfs-server:1 \
  -t boyroywax/nfs-server:latest \
  -t boyroywax/nfs-server:standard \
  --build-arg VERSION=1.0.1 \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg VCS_REF=$(git rev-parse --short HEAD) \
  .

# Minimal
docker build -f Dockerfile.minimal \
  -t boyroywax/nfs-server:1.0.1-minimal \
  --build-arg VERSION=1.0.1-minimal \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg VCS_REF=$(git rev-parse --short HEAD) \
  .

# Ultra
docker build -f Dockerfile.ultra \
  -t boyroywax/nfs-server:1.0.1-ultra \
  -t boyroywax/nfs-server:ultra \
  -t boyroywax/nfs-server:alpine \
  --build-arg VERSION=1.0.1-ultra \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg VCS_REF=$(git rev-parse --short HEAD) \
  .
```

### 2. Push All Tags

```bash
# Standard
docker push boyroywax/nfs-server:1.0.1
docker push boyroywax/nfs-server:1.0
docker push boyroywax/nfs-server:1
docker push boyroywax/nfs-server:latest
docker push boyroywax/nfs-server:standard

# Minimal
docker push boyroywax/nfs-server:1.0.1-minimal

# Ultra
docker push boyroywax/nfs-server:1.0.1-ultra
docker push boyroywax/nfs-server:ultra
docker push boyroywax/nfs-server:alpine
```

### 3. Create Git Tags

```bash
# Version tag (points to standard Dockerfile)
git tag -a v1.0.1 -m "Release v1.0.1 - Security update with multi-variant support"
git push origin v1.0.1

# Optional: Variant-specific tags for tracking
git tag -a v1.0.1-ultra -m "Ultra variant - 67% size reduction (NFSv3 only)"
git tag -a v1.0.1-minimal -m "Minimal variant - Optimized with full features"
git push origin --tags
```

### 4. Update Documentation

Update README.md to show all variants:

```markdown
## Installation

### Choose Your Variant

#### Standard (Default) - 68.6 MB
Full features: NFSv4, Kerberos, Python tools
\`\`\`bash
docker pull boyroywax/nfs-server:1.0.1
\`\`\`

#### Ultra (Lightweight) - 22.7 MB
NFSv3 only, no Kerberos, maximum optimization
\`\`\`bash
docker pull boyroywax/nfs-server:1.0.1-ultra
\`\`\`

#### Minimal (Optimized) - 62.8 MB
NFSv4 + Kerberos, size-optimized
\`\`\`bash
docker pull boyroywax/nfs-server:1.0.1-minimal
\`\`\`
```

---

## Docker Hub Description

### Short Description
```
Lightweight Alpine NFS server for Kubernetes | Standard (68MB) | Ultra (23MB) | NFSv3/v4 support
```

### Full Description
```markdown
# Alpine NFS Server - Multi-Variant

Lightweight, secure NFS server for Kubernetes with three optimized variants.

## Variants

**Standard** (default) - 68.6 MB
- NFSv3/NFSv4 support
- Kerberos authentication
- Full featured

**Ultra** - 22.7 MB (-67% size!)
- NFSv3 only
- Maximum optimization
- No Python, built from source

**Minimal** - 62.8 MB
- NFSv4 + Kerberos
- Size optimized
- POSIX compliant

## Quick Start

\`\`\`bash
# Standard (default)
docker run -d --privileged \
  -p 2049:2049 \
  boyroywax/nfs-server:1.0.1

# Ultra (lightweight)
docker run -d --privileged \
  -p 2049:2049 \
  boyroywax/nfs-server:1.0.1-ultra
\`\`\`

See GitHub for full documentation.
```

---

## Future Versioning

### Next Patch (v1.0.2)
- Continue multi-variant approach
- Security updates to all variants
- Tag: `1.0.2`, `1.0.2-ultra`, `1.0.2-minimal`

### Next Minor (v1.1.0)
- New features to standard/minimal
- Ultra remains NFSv3 optimized
- Tag: `1.1.0`, `1.1.0-ultra`, `1.1.0-minimal`

### Next Major (v2.0.0)
**Only if breaking changes to the API/configuration:**
- New configuration format
- Breaking environmental variables
- Architecture changes
- Tag: `2.0.0`, `2.0.0-ultra`, `2.0.0-minimal`

**Note:** Ultra's lack of NFSv4 is NOT a v2.0.0 trigger - it's a variant choice

---

## Rollout Plan

### Phase 1: Build & Test (Day 1)
- ✅ Build all three variants
- ✅ Test each variant
- ✅ Verify functionality
- ✅ Document differences

### Phase 2: Release (Day 2)
- [ ] Push all tags to Docker Hub
- [ ] Create GitHub release v1.0.1
- [ ] Update README with variant info
- [ ] Update Docker Hub description

### Phase 3: Communication (Day 3-7)
- [ ] Blog post about optimization journey
- [ ] Tweet about 67% size reduction
- [ ] Update Kubernetes examples
- [ ] Reddit/HN post (optional)

### Phase 4: Monitor (Ongoing)
- [ ] Track which variants are popular
- [ ] Gather user feedback
- [ ] Consider deprecating minimal if unused
- [ ] Plan future optimizations

---

## Success Metrics

### Adoption Metrics
- Docker Hub pulls by tag
- GitHub stars/forks
- Issue reports per variant
- User feedback

### Technical Metrics
- Image pull times
- Build times
- Size comparisons
- Security scan results

### Decision Points

**After 3 months:**
- If ultra > 50% pulls → Consider making ultra the default in v2.0
- If ultra < 10% pulls → Consider deprecating ultra
- If minimal ≈ standard → Consider deprecating minimal

**After 6 months:**
- Evaluate keeping all three variants
- Survey users on variant preferences
- Plan v2.0.0 strategy based on data

---

## Summary

✅ **Recommended Approach:** Multi-variant tags  
✅ **Version:** Keep v1.0.1 for all variants  
✅ **Default:** Standard remains default  
✅ **Ultra:** Available as `1.0.1-ultra`  
✅ **Benefits:** No breaking changes, user choice, easy migration  

**Next Steps:**
1. Build all variants
2. Push to Docker Hub
3. Update documentation
4. Communicate changes
5. Monitor adoption
