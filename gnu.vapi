[CCode(cheader_filename="stdlib.h")]
namespace Gnu {
        [CCode (cname = "canonicalize_file_name")]
        public string? canonicalize_file_name(string path);
}
