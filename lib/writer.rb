module WaveFile
  class WaveFileWriter
    def initialize(file_name, format)
      @file = File.open(file_name, "w")
      @format = format

      @sample_count = 0
      @pack_code = PACK_CODES[format.bits_per_sample]
      write_header(0)
    end

    def write(buffer)
      samples = buffer.convert(@format).samples

      @file.syswrite(samples.pack(@pack_code))
      @sample_count += samples.length
    end

    def close()
      @file.sysseek(0)
      write_header(@sample_count)
      
      @file.close()
    end

  private

    def write_header(sample_data_size)
      header = CHUNK_IDS[:header]
      header += [HEADER_SIZE + sample_data_size].pack("V")
      header += FORMAT
      header += CHUNK_IDS[:format]
      header += [SUB_CHUNK1_SIZE].pack("V")
      header += [PCM].pack("v")
      header += [@format.channels].pack("v")
      header += [@format.sample_rate].pack("V")
      header += [@format.byte_rate].pack("V")
      header += [@format.block_align].pack("v")
      header += [@format.bits_per_sample].pack("v")
      header += CHUNK_IDS[:data]
      header += [sample_data_size].pack("V")

      @file.syswrite(header)
    end
  end
end
