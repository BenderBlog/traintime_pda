class ForumTypeOption {
  final int id;
  final String name;

  const ForumTypeOption({required this.id, required this.name});
}

class PostPageMeta {
  final List<ForumTypeOption> typeOptions;
  final String? uploadUid;
  final String? uploadHash;
  final String? seccodeHash;
  final String? formhash;
  final String? fid;

  const PostPageMeta({
    required this.typeOptions,
    this.uploadUid,
    this.uploadHash,
    this.seccodeHash,
    this.formhash,
    this.fid,
  });
}
