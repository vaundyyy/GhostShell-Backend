package com.dsmovie;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

@EnableAsync
@SpringBootApplication
public class DsmovieApplication {

	public static void main(String[] args) {
		SpringApplication.run(DsmovieApplication.class, args);
	}

}
