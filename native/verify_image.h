static const unsigned char expected_sha[32] = {
    0x08,0x22,0x8b,0x72,0xd4,0x59,0x0f,0x9b,0x00,0xe2,0x17,0x1f,0x25,0x2d,0x61,0x84,
    0x64,0xc2,0xe0,0x4b,0x78,0x52,0x37,0xfe,0x72,0x8d,0xdd,0xbf,0x27,0xd3,0xb7,0x34
};
static bool supported_executable(void) {
    wchar_t path[32768];
    DWORD length = GetModuleFileNameW(NULL, path, 32768);
    if (!length || length >= 32768) return false;
    const wchar_t *name = wcsrchr(path, L'\\');
    if (!name || _wcsicmp(name + 1, L"VoyageSteam-Win64-Shipping.exe")) return false;
    HANDLE file = CreateFileW(path, GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,
                              NULL, OPEN_EXISTING, FILE_FLAG_SEQUENTIAL_SCAN, NULL);
    if (file == INVALID_HANDLE_VALUE) return false;
    BCRYPT_ALG_HANDLE alg = NULL;
    BCRYPT_HASH_HANDLE hash = NULL;
    unsigned char digest[32], buffer[65536];
    bool ok = BCryptOpenAlgorithmProvider(&alg, BCRYPT_SHA256_ALGORITHM, NULL, 0) >= 0;
    if (ok) ok = BCryptCreateHash(alg, &hash, NULL, 0, NULL, 0, 0) >= 0;
    DWORD read = 0;
    while (ok) {
        if (!ReadFile(file, buffer, sizeof(buffer), &read, NULL)) { ok = false; break; }
        if (!read) break;
        ok = BCryptHashData(hash, buffer, read, 0) >= 0;
    }
    if (ok) ok = BCryptFinishHash(hash, digest, sizeof(digest), 0) >= 0 && !memcmp(digest, expected_sha, 32);
    if (hash) BCryptDestroyHash(hash);
    if (alg) BCryptCloseAlgorithmProvider(alg, 0);
    CloseHandle(file);
    return ok;
}
